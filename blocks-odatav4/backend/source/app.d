import vibe.d;
import uim.fiori_blocks;

@safe:

void postLogin(HTTPServerRequest req, HTTPServerResponse res) {
  string username;
  string password;

  try {
    auto payload = req.json;

    if ("username" in payload) {
      username = payload["username"].get!string;
    }

    if ("password" in payload) {
      password = payload["password"].get!string;
    }
  } catch (Exception) {
    res.statusCode = HTTPStatus.badRequest;
    res.contentType = "application/json";
    auto errorResponse = Json.emptyObject;
    errorResponse["authenticated"] = Json(false);
    errorResponse["message"] = Json("Ungueltiger Request-Body.");
    res.writeJsonBody(errorResponse);
    return;
  }

  auto isValid = username == "admin" && password == "Welcome1!";

  if (!isValid) {
    res.statusCode = HTTPStatus.unauthorized;
    res.contentType = "application/json";
    auto unauthorizedResponse = Json.emptyObject;
    unauthorizedResponse["authenticated"] = Json(false);
    unauthorizedResponse["message"] = Json("Benutzername oder Passwort ungueltig.");
    res.writeJsonBody(unauthorizedResponse);
    return;
  }

  res.statusCode = HTTPStatus.ok;
  res.contentType = "application/json";
  auto successResponse = Json.emptyObject;
  successResponse["authenticated"] = Json(true);
  successResponse["username"] = Json(username);
  res.writeJsonBody(successResponse);
}

// OData v4 Response Wrapper
struct ODataResponse(T) {
    T value;
}

string getMetadata() {
    return `<?xml version="1.0" encoding="utf-8"?>
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
</edmx:Edmx>`;
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
    // router.any("*", (req, res) {
    //     res.headers["Access-Control-Allow-Origin"] = "*";
    //     res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
    //     res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, OData-MaxVersion";
    //     if (req.method == HTTPMethod.OPTIONS) {
    //         res.writeBody("");
    //         return;
    //     }
    // });

    // router.registerWebInterface(new ODataService);
    // router.get("/odata/v4/$metadata", &getMetadata);

    auto odataRouter = new ODataRouter();
    odataRouter.cachedMetadata = getMetadata();

    // Register OData controllers
    auto architectureOData = new ArchitectureODataController(new ManageArchitectureUseCase(new ArchitectureRepository));
    odataRouter.registerController("ArchitectureBlocks", architectureOData);

    auto baseOData = new BaseODataController(new ManageBaseUseCase(new BaseRepository));
    odataRouter.registerController("BaseBlocks", baseOData);

    auto solutionOData = new SolutionODataController(new ManageSolutionUseCase(new SolutionRepository));
    odataRouter.registerController("SolutionBlocks", solutionOData);

    auto interfaceOData = new InterfaceODataController(new ManageInterfaceUseCase(new InterfaceRepository));
    odataRouter.registerController("InterfaceBlocks", interfaceOData);

    /// Activate CORS and OData routes
    router.any("*", &enableCORS);

    // Demo authentication endpoint used by the Login view.
    router.post("/api/auth/login", &postLogin);

    // Register OData routes under /api/v4
    odataRouter.registerRoutes(router, "/odata/v4");

    // Serve static files at the end
    router.get("*", serveStaticFiles("public/"));

	foreach (route; router.getAllRoutes) {
		writefln("%-7s %s", route.method, route.pattern);
	}
	writeln("--------------------------");
    // auto base = new BaseOdataController(new ManageBaseUseCase(new BaseRepository));
    // base.registerRoutes(router);

    // auto architecture = new ArchitectureOdataController(
    //     new ManageArchitectureUseCase(new ArchitectureRepository));
    // architecture.registerRoutes(router);

    // auto solution = new SolutionOdataController(new ManageSolutionUseCase(new SolutionRepository));
    // solution.registerRoutes(router);

    // auto interface_ = new InterfaceOdataController(
    //     new ManageInterfaceUseCase(new InterfaceRepository));
    // interface_.registerRoutes(router);

    router.post("/odata/v4/$batch", &postBatch);
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    runApplication();
}
