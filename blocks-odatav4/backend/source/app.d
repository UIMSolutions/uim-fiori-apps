import vibe.d;
import uim.fiori_blocks;

@safe:

// OData v4 Response Wrapper
struct ODataResponse(T) {
    T value;
}

void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
    res.contentType = "application/xml;charset=utf-8";
    res.headers["OData-Version"] = "4.0";
    res.writeBody(`<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="EAModel" xmlns="http://docs.oasis-open.org/odata/ns/edm">
        
        <EntityType Name="BaseBlock">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Responsible" Type="Edm.String" />
        <Property Name="Version" Type="Edm.String" />
        <Property Name="Date" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="AdditionalInformation" Type="Collection(Edm.String)" />
      </EntityType>
      
      <EntityType Name="ArchitectureBlock">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Responsible" Type="Edm.String" />
        <Property Name="Version" Type="Edm.String" />
        <Property Name="Modul" Type="Edm.String" />
        <Property Name="Service" Type="Edm.String" />
        <Property Name="Product" Type="Edm.String" />
        <Property Name="Date" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="AdditionalInfo" Type="Edm.String" />
        <NavigationProperty Name="DependsOn" Type="Collection(EAModel.ArchitectureBlock)" />
      </EntityType>
      <EntityType Name="SolutionBlock">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Type" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="Status" Type="Edm.String" />
      </EntityType><EntityType Name="SolutionBlock">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Title" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="ValidFrom" Type="Edm.String" />
        <Property Name="ValidUntil" Type="Edm.String" />
        <Property Name="Version" Type="Edm.String" />
        <Property Name="Date" Type="Edm.String" />
        <Property Name="AdditionalInfo" Type="Edm.String" />
        <Property Name="Responsibles" Type="Edm.String" />
        <Property Name="DependsOnSolutionBlocks" Type="Collection(EAModel.Dependency)" />
      </EntityType>
      <EntityType Name="InterfaceBlock">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Type" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="Status" Type="Edm.String" />
      </EntityType>
      <EntityContainer Name="EAService">
        <EntitySet Name="ArchitectureBlocks" EntityType="EAModel.ArchitectureBlock" />
        <EntitySet Name="SolutionBlocks" EntityType="EAModel.SolutionBlock" />
        <EntitySet Name="InterfaceBlocks" EntityType="EAModel.InterfaceBlock" />
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`);
}

void getInterfaceBlockById(HTTPServerRequest req, HTTPServerResponse res) {
    import std.algorithm : find;
    import std.array : array;
    import std.string : strip, chomp, chompPrefix;

    string rawId = req.params["id"];
    // Entfernt OData ' Encodings falls vorhanden
    if (rawId.startsWith("'") && rawId.endsWith("'")) {
        rawId = rawId[1 .. $ - 1];
    }

    auto interfaces = new InterfaceRepository;
    auto match = interfaces.findById(rawId);

    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    if (match.ID !is null) {
        // Einzelergebnis in OData v4 ist direkt das Objekt (kein "value": [] Wrapper!)
        res.writeJsonBody(match.toJson);
    } else {
        res.statusCode = HTTPStatus.notFound;
        res.writeBody("Entity not found");
    }
}

void getInterfaceBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getInterfaceBlocks called");
    string filterQuery = req.params.get("$filter", "");

    auto interfaces = new InterfaceRepository;
    InterfaceBlock[] blocks = interfaces.findAll();

    res.headers["OData-Version"] = "4.0";
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
}

void getInterfaceBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getInterfaceBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/InterfaceBlocks('IF-02')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
        writeln("No specific ID provided, returning all Interface blocks");

        auto interfaces = new InterfaceRepository;
        auto filtered = interfaces.findAll
            .filter!(b => b.Type == "Interface")
            .map!(b => b.toJson)
            .array
            .toJson;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeJsonBody(Json.emptyObject.set("value", filtered));
        return;
    }

    writeln("Extracting raw ID from request path: ", requestPath);
    // 2. ID aus den Klammern extrahieren
    string rawId = requestPath[startIdx + 1 .. endIdx].strip();

    // Anführungszeichen entfernen: 'IF-02' -> IF-02
    if (rawId.startsWith("'") && rawId.endsWith("'") && rawId.length >= 2) {
        rawId = rawId[1 .. $ - 1];
    }

    // 3. Einzelnen Datensatz suchen
    writeln("Searching for Interface block with ID: ", rawId);
    auto interfaces = new InterfaceRepository;
    auto match = interfaces.findAll.filter!(b => b.ID == rawId).array;

    if (!match.empty) {
        // Einzel-Objekt in OData v4 wird OHNE {"value": [...]} Wrapper gesendet!
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        auto response = match[0].toJson.set("@odata.context", "$metadata#InterfaceBlocks/$entity");
        writeln("Response JSON for single Interface block: ", response);
        res.writeJsonBody(response);
    } else {
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.statusCode = HTTPStatus.notFound;
        res.writeJsonBody(["error": "Entity not found"]);
    }
}

void getArchitectureBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getArchitectureBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/ArchitectureBlocks('AB-01')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
        writeln("No specific ID provided, returning all Architecture blocks");

        auto architecture = new ArchitectureRepository;
        auto filtered = architecture.findAll.map!(b => b.toJson).array.toJson;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeJsonBody(Json.emptyObject.set("value", filtered));
        return;
    }

    writeln("Extracting raw ID from request path: ", requestPath);
    // 2. ID aus den Klammern extrahieren
    string rawId = requestPath[startIdx + 1 .. endIdx].strip();

    // Anführungszeichen entfernen: 'IF-02' -> IF-02
    if (rawId.startsWith("'") && rawId.endsWith("'") && rawId.length >= 2) {
        rawId = rawId[1 .. $ - 1];
    }

    // 3. Einzelnen Datensatz suchen
    writeln("Searching for Architecture block with ID: ", rawId);
    auto architecture = new ArchitectureRepository;
    auto match = architecture.findAll.filter!(b => b.ID == rawId).array;

    if (!match.empty) {
        // Einzel-Objekt in OData v4 wird OHNE {"value": [...]} Wrapper gesendet!
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        auto response = match[0].toJson.set("@odata.context", "$metadata#ArchitectureBlocks/$entity");
        writeln("Response JSON for single Architecture block: ", response);
        res.writeJsonBody(response);
    } else {
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.statusCode = HTTPStatus.notFound;
        res.writeJsonBody(["error": "Entity not found"]);
    }
}

void getSolutionBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getSolutionBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/SolutionBlocks('SB-01')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
        writeln("No specific ID provided, returning all Solution blocks");

        auto solution = new SolutionRepository;
        auto filtered = solution.findAll.map!(b => b.toJson).array.toJson;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeJsonBody(Json.emptyObject.set("value", filtered));
        return;
    }

    writeln("Extracting raw ID from request path: ", requestPath);
    // 2. ID aus den Klammern extrahieren
    string rawId = requestPath[startIdx + 1 .. endIdx].strip();

    // Anführungszeichen entfernen: 'IF-02' -> IF-02
    if (rawId.startsWith("'") && rawId.endsWith("'") && rawId.length >= 2) {
        rawId = rawId[1 .. $ - 1];
    }

    // 3. Einzelnen Datensatz suchen
    writeln("Searching for Solution block with ID: ", rawId);
    auto solution = new SolutionRepository;
    auto match = solution.findAll.filter!(b => b.ID == rawId).array;

    if (!match.empty) {
        // Einzel-Objekt in OData v4 wird OHNE {"value": [...]} Wrapper gesendet!
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        auto response = match[0].toJson.set("@odata.context", "$metadata#SolutionBlocks/$entity");
        writeln("Response JSON for single Solution block: ", response);
        res.writeJsonBody(response);
    } else {
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.statusCode = HTTPStatus.notFound;
        res.writeJsonBody(["error": "Entity not found"]);
    }
}

void getSolutionBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getSolutionBlocks called");
    string filterQuery = req.params.get("$filter", "");

    auto solution = new SolutionRepository;
    SolutionBlock[] blocks = solution.findAll;

    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
}

void getArchitectureBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getArchitectureBlocks called");
    string filterQuery = req.params.get("$filter", "");

    auto architecture = new ArchitectureRepository;
    ArchitectureBlock[] blocks = architecture.findAll;

    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
}

// POST /odata/v4/$batch (Fallback Handler für UI5 Batch Requests)
void postBatch(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("Received batch request, which is not implemented.");

    // Antworten, dass Batch-Requests nicht unterstützt werden, oder Direct Requests anfordern
    res.statusCode = HTTPStatus.notImplemented;
    res.writeBody("Batch processing not implemented. Use direct requests ($direct).");
}

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    // CORS Header setzen
    router.any("*", (req, res) {
        res.headers["Access-Control-Allow-Origin"] = "*";
        res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
        res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, OData-MaxVersion";
        if (req.method == HTTPMethod.OPTIONS) {
            res.writeBody("");
            return;
        }
    });

    // router.registerWebInterface(new ODataService);
    router.get("/odata/v4/$metadata", &getMetadata);
    router.get("/odata/v4/SolutionBlocks*", &getSolutionBlockByIdOrAll);
    router.get("/odata/v4/InterfaceBlocks*", &getInterfaceBlockByIdOrAll);
    router.get("/odata/v4/ArchitectureBlocks*", &getArchitectureBlockByIdOrAll);
    router.post("/odata/v4/$batch", &postBatch);
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    runApplication();
}
