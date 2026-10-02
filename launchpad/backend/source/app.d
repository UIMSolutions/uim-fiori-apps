module app;

import vibe.vibe;
import std.conv : to;
import std.process : environment;
import std.algorithm : min, startsWith, endsWith;
import std.json : JSONValue, JSONType, parseJSON;

struct Product {
    string ID;
    string name;
    string category;
    double price;
    int stock;
    string currency;
}

Product[] products = [
    Product("P-1000", "Steel Bolt", "Hardware", 0.35, 540, "EUR"),
    Product("P-1001", "Copper Pipe", "Plumbing", 14.20, 125, "EUR"),
    Product("P-1002", "Safety Helmet", "Protection", 22.90, 84, "EUR"),
    Product("P-1003", "Industrial Glue", "Chemicals", 8.10, 300, "EUR"),
    Product("P-1004", "Aluminum Sheet", "Metals", 31.75, 48, "EUR"),
    Product("P-1005", "Rubber Seal", "Hardware", 1.15, 900, "EUR")
];

immutable string METADATA_XML =
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        ~ "<edmx:Edmx Version=\"4.0\" xmlns:edmx=\"http://docs.oasis-open.org/odata/ns/edmx\">\n"
        ~ "  <edmx:DataServices>\n"
        ~ "    <Schema Namespace=\"LaunchpadService\" xmlns=\"http://docs.oasis-open.org/odata/ns/edm\">\n"
        ~ "      <EntityType Name=\"Product\">\n"
        ~ "        <Key>\n"
        ~ "          <PropertyRef Name=\"ID\" />\n"
        ~ "        </Key>\n"
        ~ "        <Property Name=\"ID\" Type=\"Edm.String\" Nullable=\"false\" />\n"
        ~ "        <Property Name=\"Name\" Type=\"Edm.String\" Nullable=\"false\" />\n"
        ~ "        <Property Name=\"Category\" Type=\"Edm.String\" Nullable=\"false\" />\n"
        ~ "        <Property Name=\"Price\" Type=\"Edm.Decimal\" Nullable=\"false\" Scale=\"2\" Precision=\"16\" />\n"
        ~ "        <Property Name=\"Stock\" Type=\"Edm.Int32\" Nullable=\"false\" />\n"
        ~ "        <Property Name=\"Currency\" Type=\"Edm.String\" Nullable=\"false\" />\n"
        ~ "      </EntityType>\n"
        ~ "      <EntityContainer Name=\"Container\">\n"
        ~ "        <EntitySet Name=\"Products\" EntityType=\"LaunchpadService.Product\" />\n"
        ~ "      </EntityContainer>\n"
        ~ "    </Schema>\n"
        ~ "  </edmx:DataServices>\n"
        ~ "</edmx:Edmx>\n";

void enableCORS(HTTPServerRequest req, HTTPServerResponse res)
{
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With";

    if (req.method == HTTPMethod.OPTIONS) {
        res.statusCode = 204;
        res.writeBody("");
    }
}

size_t parseTop(HTTPServerRequest req)
{
    auto topParam = req.query.get("$top", "");
    if (topParam.length == 0) {
        return products.length;
    }

    try {
        auto parsed = to!size_t(topParam);
        return min(parsed, products.length);
    } catch (Exception) {
        return products.length;
    }
}

void writeJson(HTTPServerResponse res, JSONValue payload, int status = 200)
{
    res.statusCode = status;
    res.contentType = "application/json";
    res.writeBody(payload.toString());
}

JSONValue toODataProduct(ref const(Product) p)
{
    JSONValue item;
    item["ID"] = p.ID;
    item["Name"] = p.name;
    item["Category"] = p.category;
    item["Price"] = p.price;
    item["Stock"] = p.stock;
    item["Currency"] = p.currency;
    return item;
}

JSONValue errorPayload(string message)
{
    JSONValue payload;
    payload["error"] = message;
    return payload;
}

string extractProductIdFromPath(string path)
{
    enum prefix = "/odata/v4/launchpad/Products";
    if (!path.startsWith(prefix)) {
        return "";
    }

    auto tail = path[prefix.length .. $];
    if (tail.length == 0) {
        return "";
    }

    if (tail[0] == '/') {
        return tail[1 .. $];
    }

    if (tail[0] == '(' && tail.endsWith(")")) {
        auto key = tail[1 .. $ - 1];
        if (key.length >= 2 && key[0] == '\'' && key[$ - 1] == '\'') {
            key = key[1 .. $ - 1];
        }
        return key;
    }

    return "";
}

ptrdiff_t findProductIndex(string id)
{
    foreach (i, p; products) {
        if (p.ID == id) {
            return cast(ptrdiff_t)i;
        }
    }

    return -1;
}

string stringField(JSONValue[string] obj, string key, string defaultValue = "")
{
    if (auto val = key in obj) {
        if ((*val).type == JSONType.string) {
            return (*val).str;
        }
        return (*val).toString();
    }
    return defaultValue;
}

double numberField(JSONValue[string] obj, string key, double defaultValue = 0)
{
    if (auto val = key in obj) {
        switch ((*val).type) {
            case JSONType.float_:
                return (*val).floating;
            case JSONType.integer:
                return cast(double)(*val).integer;
            case JSONType.uinteger:
                return cast(double)(*val).uinteger;
            case JSONType.string:
                return to!double((*val).str);
            default:
                return defaultValue;
        }
    }
    return defaultValue;
}

int intField(JSONValue[string] obj, string key, int defaultValue = 0)
{
    if (auto val = key in obj) {
        switch ((*val).type) {
            case JSONType.integer:
                return cast(int)(*val).integer;
            case JSONType.uinteger:
                return cast(int)(*val).uinteger;
            case JSONType.float_:
                return cast(int)(*val).floating;
            case JSONType.string:
                return to!int((*val).str);
            default:
                return defaultValue;
        }
    }
    return defaultValue;
}

void getMetadata(HTTPServerRequest req, HTTPServerResponse res)
{
    res.contentType = "application/xml";
    res.writeBody(METADATA_XML);
}

void getProducts(HTTPServerRequest req, HTTPServerResponse res)
{
    auto top = parseTop(req);
    JSONValue[] items;

    foreach (p; products[0 .. top]) {
        items ~= toODataProduct(p);
    }

    JSONValue payload;
    payload["@odata.context"] = "$metadata#Products";
    payload["value"] = items;

    writeJson(res, payload);
}

void getProductById(HTTPServerRequest req, HTTPServerResponse res)
{
    auto id = extractProductIdFromPath(req.requestPath.toString());
    auto idx = findProductIndex(id);

    if (id.length == 0 || idx < 0) {
        writeJson(res, errorPayload("Product not found"), 404);
        return;
    }

    JSONValue payload = toODataProduct(products[idx]);
    payload["@odata.context"] = "$metadata#Products/$entity";
    writeJson(res, payload);
}

void createProduct(HTTPServerRequest req, HTTPServerResponse res)
{
    try {
        auto raw = req.bodyReader.readAllUTF8();
        auto body = parseJSON(raw);

        if (body.type != JSONType.object) {
            writeJson(res, errorPayload("Invalid JSON payload"), 400);
            return;
        }

        auto obj = body.object;
        auto id = stringField(obj, "ID");
        if (id.length == 0) {
            id = "P-" ~ to!string(2000 + cast(int)products.length);
        }

        if (findProductIndex(id) >= 0) {
            writeJson(res, errorPayload("Product with this ID already exists"), 409);
            return;
        }

        Product p;
        p.ID = id;
        p.name = stringField(obj, "Name", "Unnamed Product");
        p.category = stringField(obj, "Category", "General");
        p.price = numberField(obj, "Price", 0);
        p.stock = intField(obj, "Stock", 0);
        p.currency = stringField(obj, "Currency", "EUR");
        products ~= p;

        auto payload = toODataProduct(products[$ - 1]);
        payload["@odata.context"] = "$metadata#Products/$entity";
        writeJson(res, payload, 201);
    } catch (Exception ex) {
        writeJson(res, errorPayload("Unable to create product: " ~ ex.msg), 400);
    }
}

void updateProduct(HTTPServerRequest req, HTTPServerResponse res)
{
    auto id = extractProductIdFromPath(req.requestPath.toString());
    auto idx = findProductIndex(id);

    if (id.length == 0 || idx < 0) {
        writeJson(res, errorPayload("Product not found"), 404);
        return;
    }

    try {
        auto raw = req.bodyReader.readAllUTF8();
        auto body = parseJSON(raw);
        if (body.type != JSONType.object) {
            writeJson(res, errorPayload("Invalid JSON payload"), 400);
            return;
        }

        auto obj = body.object;
        if ("Name" in obj) {
            products[idx].name = stringField(obj, "Name", products[idx].name);
        }
        if ("Category" in obj) {
            products[idx].category = stringField(obj, "Category", products[idx].category);
        }
        if ("Price" in obj) {
            products[idx].price = numberField(obj, "Price", products[idx].price);
        }
        if ("Stock" in obj) {
            products[idx].stock = intField(obj, "Stock", products[idx].stock);
        }
        if ("Currency" in obj) {
            products[idx].currency = stringField(obj, "Currency", products[idx].currency);
        }

        auto payload = toODataProduct(products[idx]);
        payload["@odata.context"] = "$metadata#Products/$entity";
        writeJson(res, payload);
    } catch (Exception ex) {
        writeJson(res, errorPayload("Unable to update product: " ~ ex.msg), 400);
    }
}

void deleteProduct(HTTPServerRequest req, HTTPServerResponse res)
{
    auto id = extractProductIdFromPath(req.requestPath.toString());
    auto idx = findProductIndex(id);

    if (id.length == 0 || idx < 0) {
        writeJson(res, errorPayload("Product not found"), 404);
        return;
    }

    products = products[0 .. idx] ~ products[idx + 1 .. $];
    res.statusCode = 204;
    res.writeBody("");
}

void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res)
{
    JSONValue endpoint;
    endpoint["name"] = "Products";
    endpoint["kind"] = "EntitySet";
    endpoint["url"] = "Products";

    JSONValue payload;
    payload["@odata.context"] = "$metadata";
    payload["value"] = [endpoint];

    writeJson(res, payload);
}

void handleProductById(HTTPServerRequest req, HTTPServerResponse res)
{
    switch (req.method) {
        case HTTPMethod.GET:
            getProductById(req, res);
            return;
        case HTTPMethod.PUT:
            updateProduct(req, res);
            return;
        case HTTPMethod.DELETE:
            deleteProduct(req, res);
            return;
        default:
            res.statusCode = 405;
            res.writeBody("Method Not Allowed");
            return;
    }
}

void main()
{
    auto router = new URLRouter();
    router.any("*", &enableCORS);

    router.get("/odata/v4/launchpad/$metadata", &getMetadata);
    router.get("/odata/v4/launchpad/Products", &getProducts);
    router.any("/odata/v4/launchpad/Products/*", &handleProductById);
    router.post("/odata/v4/launchpad/Products", &createProduct);
    router.get("/odata/v4/launchpad/", &getServiceDocument);
    router.get("/health", (req, res) {
        res.writeBody("OK");
    });

    auto settings = new HTTPServerSettings();
    settings.bindAddresses = ["0.0.0.0"];
    settings.port = to!ushort(environment.get("PORT", "8080"));

    listenHTTP(settings, router);
    logInfo("Launchpad backend listening on http://localhost:%s/odata/v4/launchpad/", settings.port);
    runApplication();
}
