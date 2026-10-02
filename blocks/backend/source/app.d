module app;

import vibe.vibe;

struct ArchitectureBlock {
    string id;
    string name;
    string domain;
    string eaLayer;
    string responsible;
    string status;
}

// In-Memory Speicher für Demo-Zwecke
private ArchitectureBlock[] g_blocks;

shared static this() {
    g_blocks = [
        ArchitectureBlock("1", "Payment Service", "Finance", "Business", "Max Mustermann", "Active"),
        ArchitectureBlock("2", "User Auth Gateway", "Security", "Infrastructure", "Erika Musterfrau", "Active"),
        ArchitectureBlock("3", "Order Processing", "Logistics", "Application", "John Doe", "Draft")
    ];
}

struct Notification {
    string id;
    string title;
    string description;
    string icon;
    string infoState; // e.g. "Success", "Warning", "Error", "Information"
}

class NotificationService {
    // Endpunkt: GET /odata/v4/Notifications
    void getNotifications(HTTPServerRequest req, HTTPServerResponse res) {
        Notification[] list = [
            Notification("1", "vibe.d OData Service", "Backend-Verbindung aktiv", "sap-icon://accept", "Success"),
            Notification("2", "Architecture Block hinzugefügt", "Neuer Baustein 'CRM Core' erfasst", "sap-icon://sys-enter-2", "Information"),
            Notification("3", "System Monitor", "Hohe Auslastung auf Service 'Auth'", "sap-icon://alert", "Warning")
        ];

        // OData v4 JSON-Format
        Json responseJson = Json.emptyObject;
        responseJson["value"] = serializeToJson(list);

        res.writeJsonBody(responseJson);
    }
}

void registerNotificationRoutes(URLRouter router) {
    auto service = new NotificationService();
    router.get("/odata/v4/Notifications", &service.getNotifications);
}

void handleCORS2(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With, Accept, OData-Version, OData-MaxVersion, x-sap-security-session, mime-version";

    // Preflight-Anfragen sofort mit 200/204 beantworten
    if (req.method == HTTPMethod.OPTIONS) {
        res.statusCode = 200;
        res.writeBody("");
        return;
    }
}

void handleODataBatch(HTTPServerRequest req, HTTPServerResponse res) {
    string boundary = "batchresponse_12345";

    // Content-Type MUSS den Boundary-Parameter enthalten
    res.headers["Content-Type"] = "multipart/mixed; boundary=" ~ boundary;
    res.headers["OData-Version"] = "4.0";
    res.statusCode = 200;

    // Body mit zwei Bindestrichen vor dem Boundary
    auto body = "--" ~ boundary ~ "\r\n" ~
        "Content-Type: application/http\r\n" ~
        "Content-Transfer-Encoding: binary\r\n\r\n" ~
        "HTTP/1.1 200 OK\r\n" ~
        "Content-Type: application/json; odata.metadata=minimal\r\n\r\n" ~
        "{\"@odata.context\":\"$metadata#ArchitectureBlocks\",\"value\":[]}\r\n" ~
        "--" ~ boundary ~ "--\r\n";

    res.writeBody(body);
}

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    // CORS Middleware für die Fiori UI5 Entwicklung
    router.any("*", &handleCORS2);

    // OData v4 Endpunkte
    router.get("/odata/v4/$metadata", &handleMetadata);
    router.post("/odata/v4/$batch", &handleODataBatch);
    router.get("/odata/v4/ArchitectureBlocks", &handleGetBlocks);
    registerNotificationRoutes(router);
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    runApplication();
}

void handleCORS(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, OData-Version, OData-MaxVersion";

    if (req.method == HTTPMethod.OPTIONS) {
        res.statusCode = HTTPStatus.noContent; // 204 No Content
        res.writeBody(""); // Sendet leeren Body
        return;
    }
}

void handleMetadata(HTTPServerRequest req, HTTPServerResponse res) @safe {
    res.contentType = "application/xml";
    res.writeBody(`<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="EAManager" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="ArchitectureBlock">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String"/>
        <Property Name="Domain" Type="Edm.String"/>
        <Property Name="EaLayer" Type="Edm.String"/>
        <Property Name="Responsible" Type="Edm.String"/>
        <Property Name="Status" Type="Edm.String"/>
      </EntityType>
      <EntityContainer Name="EAManagerService">
        <EntitySet Name="ArchitectureBlocks" EntityType="EAManager.ArchitectureBlock"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`);
}

void handleGetBlocks(HTTPServerRequest req, HTTPServerResponse res) @safe {
    Json responseJson = Json.emptyObject;
    responseJson["@odata.context"] = "$metadata#ArchitectureBlocks";

    Json valueArray = Json.emptyArray;
    foreach (block; g_blocks) {
        Json item = Json.emptyObject;
        item["ID"] = block.id;
        item["Name"] = block.name;
        item["Domain"] = block.domain;
        item["EaLayer"] = block.eaLayer;
        item["Responsible"] = block.responsible;
        item["Status"] = block.status;
        valueArray ~= item;
    }
    responseJson["value"] = valueArray;

    res.writeJsonBody(responseJson);
}
