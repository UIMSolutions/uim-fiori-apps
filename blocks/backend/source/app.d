module app;

import vibe.vibe;

struct ArchitectureBlock {
    string ID;
    string Name;
    string Domain;
    string EaLayer;
    string Responsible;
    string Status;
}

// In-Memory Speicher für Demo-Zwecke
private ArchitectureBlock[] g_blocks;

shared static this() {
    g_blocks = [
        ArchitectureBlock("1", "Payment Service", "Finance", "Business", "Max Mustermann", "Active"),
        ArchitectureBlock("2", "User Auth Gateway", "Security", "Infrastructure", "Erika Musterfrau", "Active"),
        ArchitectureBlock("3", "Order Processing", "Logistics", "Application", "John Doe", "Draft")
    ];

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    // CORS Middleware für die Fiori UI5 Entwicklung
    router.any("*", &handleCORS);

    // OData v4 Endpunkte
    router.get("/odata/v4/$metadata", &handleMetadata);
    router.get("/odata/v4/ArchitectureBlocks", &handleGetBlocks);

    listenHTTP(settings, router);
}

void handleCORS(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, OData-Version, OData-MaxVersion";
    
    if (req.method == HTTPMethod.OPTIONS) {
        res.writeVoid();
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
        item["ID"] = block.ID;
        item["Name"] = block.Name;
        item["Domain"] = block.Domain;
        item["EaLayer"] = block.EaLayer;
        item["Responsible"] = block.Responsible;
        item["Status"] = block.Status;
        valueArray.appendJsonFragment(item);
    }
    responseJson["value"] = valueArray;

    res.writeJsonBody(responseJson);
}