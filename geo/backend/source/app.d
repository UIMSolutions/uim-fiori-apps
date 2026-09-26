import vibe.vibe;
import std.algorithm : endsWith, filter, startsWith;
import std.conv : to;
import std.array : join;
import std.file : readText;
import std.process : environment;
import std.string : split, strip, toLower;
import config;
import database;

void writeODataJson(HTTPServerResponse res, Json value, int status = 200) {
    res.statusCode = status;
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";
    res.headers["Cache-Control"] = "no-store";
    res.writeBody(value.toString());
}

bool authorized(HTTPServerRequest req) {
    return req.headers.get("Authorization", "").startsWith("Bearer ");
}

string queryValue(HTTPServerRequest req, string name) {
    auto value = name in req.query;
    return value is null ? "" : *value;
}

LocationQuery parseLocationQuery(HTTPServerRequest req) {
    LocationQuery result;
    auto countText = queryValue(req, "$count").toLower;
    if (countText.length) {
        if (countText == "true")
            result.includeCount = true;
        else if (countText == "false")
            result.includeCount = false;
        else
            throw new Exception("$count muss true oder false sein");
    }
    auto topText = queryValue(req, "$top");
    if (topText.length) {
        auto parsed = topText.to!uint;
        if (parsed == 0 || parsed > 500)
            throw new Exception("$top muss zwischen 1 und 500 liegen");
        result.top = parsed;
    }
    auto skipText = queryValue(req, "$skip");
    if (skipText.length) {
        auto parsed = skipText.to!uint;
        if (parsed > 1_000_000)
            throw new Exception("$skip darf höchstens 1000000 sein");
        result.skip = parsed;
    }

    auto orderBy = queryValue(req, "$orderby").strip;
    if (orderBy.length) {
        auto parts = orderBy.split;
        if (parts.length > 2)
            throw new Exception("Ungültiges $orderby");
        string[string] columns = [
            "id": "id", "name": "name", "category": "category",
            "createdat": "created_at"
        ];
        auto key = parts[0].toLower;
        if (key !in columns)
            throw new Exception("Feld in $orderby nicht erlaubt");
        result.orderColumn = columns[key];
        if (parts.length == 2) {
            auto direction = parts[1].toLower;
            if (direction != "asc" && direction != "desc")
                throw new Exception("Sortierrichtung muss asc oder desc sein");
            result.descending = direction == "desc";
        }
    }

    auto filter = queryValue(req, "$filter").strip;
    if (filter.length) {
        auto parts = filter.split(" eq ");
        if (parts.length != 2)
            throw new Exception("Unterstützt wird: Feld eq 'Wert'");
        string[string] columns = [
            "ID": "id", "Name": "name", "Category": "category"
        ];
        auto field = parts[0].strip;
        auto literal = parts[1].strip;
        if (field !in columns || literal.length < 2 || literal[0] != '\'' || !literal.endsWith("'"))
            throw new Exception("Ungültiges $filter");
        result.filterColumn = columns[field];
        result.filterValue = literal[1 .. $ - 1];
    }
    return result;
}

Json pageAsOData(LocationPage page, LocationQuery options, string rawQuery) {
    auto response = Json([
        "@odata.context": Json("$metadata#Locations"),
        "value": Json(page.values)
    ]);
    if (options.includeCount)
        response["@odata.count"] = Json(page.totalCount);
    auto next = cast(ulong)options.skip + options.top;
    if (page.hasMore) {
        auto queryParts = rawQuery.split("&").filter!(part => !part.startsWith("$skip="));
        auto query = queryParts.join("&");
        string separator = query.length ? "&" : "?";
        response["@odata.nextLink"] = Json("Locations" ~ (query.length ? "?" ~ query : "") ~ separator ~ "$skip=" ~ next
                .to!string);
    }
    return response;
}

void main() {
    auto repository = new LocationRepository(postgresConnInfo());
    repository.migrate();
    immutable metadata = readText("metadata.xml");
    auto router = new URLRouter;

    router.get("/health", (HTTPServerRequest req, HTTPServerResponse res) {
        writeODataJson(res, Json(["status": Json("UP")]));
    });
    router.get("/odata/v4/geo/", (HTTPServerRequest req, HTTPServerResponse res) {
        if (!authorized(req)) {
            writeODataJson(res, Json([
                    "error": Json([
                        "code": Json("401"),
                        "message": Json("Unauthorized")
                    ])
                ]), 401);
            return;
        }
        writeODataJson(res, Json([
                "@odata.context": Json("$metadata"),
                "value": Json([
                    Json([
                        "name": Json("Locations"),
                        "kind": Json("EntitySet"),
                        "url": Json("Locations")
                    ])
                ])
            ]));
    });
    router.get("/odata/v4/geo/$metadata", (HTTPServerRequest req, HTTPServerResponse res) {
        if (!authorized(req)) {
            writeODataJson(res, Json([
                    "error": Json([
                        "code": Json("401"),
                        "message": Json("Unauthorized")
                    ])
                ]), 401);
            return;
        }
        res.headers["Content-Type"] = "application/xml;charset=utf-8";
        res.headers["OData-Version"] = "4.0";
        res.writeBody(metadata);
    });
    router.get("/odata/v4/geo/Locations", (HTTPServerRequest req, HTTPServerResponse res) {
        if (!authorized(req)) {
            writeODataJson(res, Json([
                    "error": Json([
                        "code": Json("401"),
                        "message": Json("Unauthorized")
                    ])
                ]), 401);
            return;
        }
        try {
            auto options = parseLocationQuery(req);
            writeODataJson(res, pageAsOData(repository.page(options), options, req.queryString));
        } catch (Exception error) {
            writeODataJson(res, Json([
                    "error": Json([
                        "code": Json("400"),
                        "message": Json(error.msg)
                    ])
                ]), 400);
        }
    });
    router.any("*", (HTTPServerRequest req, HTTPServerResponse res) {
        writeODataJson(res, Json([
                "error": Json([
                    "code": Json("404"),
                    "message": Json("Not Found")
                ])
            ]), 404);
    });

    auto settings = new HTTPServerSettings;
    settings.port = environment.get("PORT", "8080").to!ushort;
    settings.bindAddresses = ["0.0.0.0"];
    listenHTTP(settings, router);
    runApplication();
}
