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
      </EntityType>
      
      <EntityType Name="SolutionBlock">
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
        <EntitySet Name="BaseBlocks" EntityType="EAModel.BaseBlock" />
        <EntitySet Name="ArchitectureBlocks" EntityType="EAModel.ArchitectureBlock" />
        <EntitySet Name="SolutionBlocks" EntityType="EAModel.SolutionBlock" />
        <EntitySet Name="InterfaceBlocks" EntityType="EAModel.InterfaceBlock" />
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`);
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

    auto batch = new BatchOdataController(new ManageBaseUseCase(new BaseRepository));
    batch.registerRoutes(router);

    auto base = new BaseOdataController(new ManageBaseUseCase(new BaseRepository));
    base.registerRoutes(router);

    auto architecture = new ArchitectureOdataController(new ManageArchitectureUseCase(new ArchitectureRepository));
    architecture.registerRoutes(router);

    auto solution = new SolutionOdataController(new ManageSolutionUseCase(new SolutionRepository));
    solution.registerRoutes(router);

    auto interface_ = new InterfaceOdataController(new ManageInterfaceUseCase(new InterfaceRepository));
    interface_.registerRoutes(router);

    router.post("/odata/v4/$batch", &postBatch);
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    runApplication();
}
