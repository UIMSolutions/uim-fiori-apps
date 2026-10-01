module app;

import vibe.vibe;
import std.conv : to;
import std.process : environment;
import std.algorithm : min;
import std.json : JSONValue;

struct Product {
    string ID;
    string name;
    string category;
    double price;
    int stock;
    string currency;
}

immutable Product[] PRODUCTS = [
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
        return PRODUCTS.length;
    }

    try {
        auto parsed = to!size_t(topParam);
        return min(parsed, PRODUCTS.length);
    } catch (Exception) {
        return PRODUCTS.length;
    }
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

    foreach (p; PRODUCTS[0 .. top]) {
        JSONValue item;
        item["ID"] = p.ID;
        item["Name"] = p.name;
        item["Category"] = p.category;
        item["Price"] = p.price;
        item["Stock"] = p.stock;
        item["Currency"] = p.currency;
        items ~= item;
    }

    JSONValue payload;
    payload["@odata.context"] = "$metadata#Products";
    payload["value"] = items;

    res.contentType = "application/json";
    res.writeBody(payload.toString());
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

    res.contentType = "application/json";
    res.writeBody(payload.toString());
}

void main()
{
    auto router = new URLRouter();
    router.any("*", &enableCORS);

    router.get("/odata/v4/launchpad/$metadata", &getMetadata);
    router.get("/odata/v4/launchpad/Products", &getProducts);
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
