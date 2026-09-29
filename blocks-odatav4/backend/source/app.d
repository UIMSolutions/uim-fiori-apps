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

  auto isValid = (username == "admin" || username == "viewer") && password == "Welcome1!";

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
  auto role = username == "admin" ? "Administrator" : "Viewer";
  successResponse["authenticated"] = Json(true);
  successResponse["username"] = Json(username);
  successResponse["role"] = Json(role);
  res.writeJsonBody(successResponse);
}

void getNotifications(HTTPServerRequest req, HTTPServerResponse res) {
  res.statusCode = HTTPStatus.ok;
  res.contentType = "application/json";

  auto items = Json.emptyArray;

  auto n1 = Json.emptyObject;
  n1["title"] = Json("Import abgeschlossen");
  n1["description"] = Json("42 Datensaetze wurden erfolgreich importiert.");
  n1["timestamp"] = Json("vor 2 Minuten");
  n1["state"] = Json("Success");
  items ~= n1;

  auto n2 = Json.emptyObject;
  n2["title"] = Json("Qualitaetspruefung");
  n2["description"] = Json("6 Datensaetze enthalten fehlende Pflichtfelder.");
  n2["timestamp"] = Json("vor 10 Minuten");
  n2["state"] = Json("Warning");
  items ~= n2;

  auto n3 = Json.emptyObject;
  n3["title"] = Json("Synchronisation");
  n3["description"] = Json("Naechste automatische Synchronisation um 16:30 Uhr.");
  n3["timestamp"] = Json("soeben");
  n3["state"] = Json("Information");
  items ~= n3;

  auto response = Json.emptyObject;
  response["items"] = items;
  res.writeJsonBody(response);
}

void getLogs(HTTPServerRequest req, HTTPServerResponse res) {
  import std.algorithm : canFind;
  import std.array : array;
  import std.conv : to;
  import std.string : indexOf, replace, split, toLower;

  res.statusCode = HTTPStatus.ok;
  res.contentType = "application/json";

  static string getQueryValue(string requestUrl, string key) {
    auto qIdx = requestUrl.indexOf("?");
    if (qIdx < 0) {
      return "";
    }

    auto queryString = requestUrl[qIdx + 1 .. $];
    foreach (pair; queryString.split("&")) {
      auto kv = pair.split("=");
      if (kv.length > 0 && kv[0] == key) {
        if (kv.length > 1) {
          return kv[1].replace("+", " ").replace("%20", " ");
        }
        return "";
      }
    }

    return "";
  }

  static size_t getQuerySize(string requestUrl, string key, size_t fallback) {
    auto raw = getQueryValue(requestUrl, key);
    if (raw.length == 0) {
      return fallback;
    }

    try {
      return raw.to!size_t;
    } catch (Exception) {
      return fallback;
    }
  }

  struct LogEntry {
    string level;
    string message;
    string timestamp;
    string isoDate;
    string source;
    string user;
  }

  auto logs = [
    LogEntry("Success", "Export abgeschlossen", "2026-09-29 10:12", "2026-09-29T10:12:00", "BlockExport", "admin"),
    LogEntry(
      "Warning",
      "Pflichtfeld fehlt in 6 Datensaetzen",
      "2026-09-29 09:58",
      "2026-09-29T09:58:00",
      "QualityCheck",
      "admin"
    ),
    LogEntry("Error", "Synchronisation fehlgeschlagen", "2026-09-29 09:40", "2026-09-29T09:40:00", "SyncJob", "viewer"),
    LogEntry("Success", "Anmeldung erfolgreich", "2026-09-29 09:32", "2026-09-29T09:32:00", "Auth", "viewer")
  ];

  auto severity = getQueryValue(req.requestURL, "severity");
  auto query = getQueryValue(req.requestURL, "q").toLower;
  auto fromDate = getQueryValue(req.requestURL, "from");
  auto toDate = getQueryValue(req.requestURL, "to");
  auto limit = getQuerySize(req.requestURL, "limit", 20);
  auto offset = getQuerySize(req.requestURL, "offset", 0);

  auto filtered = logs
    .filter!(entry => severity.length == 0 || entry.level == severity)
    .filter!((entry) {
      if (query.length == 0) {
        return true;
      }
      auto haystack = (entry.message ~ " " ~ entry.source ~ " " ~ entry.user).toLower;
      return haystack.canFind(query);
    })
    .filter!((entry) {
      auto onlyDate = entry.isoDate[0 .. 10];
      if (fromDate.length > 0 && onlyDate < fromDate) {
        return false;
      }
      if (toDate.length > 0 && onlyDate > toDate) {
        return false;
      }
      return true;
    })
    .array;

  auto total = filtered.length;
  if (offset > total) {
    offset = total;
  }
  auto end = offset + limit;
  if (end > total) {
    end = total;
  }

  auto items = Json.emptyArray;
  foreach (entry; filtered[offset .. end]) {
    auto j = Json.emptyObject;
    j["level"] = Json(entry.level);
    j["message"] = Json(entry.message);
    j["timestamp"] = Json(entry.timestamp);
    j["isoDate"] = Json(entry.isoDate);
    j["source"] = Json(entry.source);
    j["user"] = Json(entry.user);
    items ~= j;
  }

  auto response = Json.emptyObject;
  response["items"] = items;
  response["total"] = Json(total);
  response["limit"] = Json(limit);
  response["offset"] = Json(offset);
  res.writeJsonBody(response);
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

      <EntityType Name="User">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Username" Type="Edm.String" />
        <Property Name="Email" Type="Edm.String" />
        <Property Name="Role" Type="Edm.String" />
        <Property Name="Active" Type="Edm.Boolean" />
      </EntityType>

      <EntityContainer Name="EAService">
        <EntitySet Name="BaseBlocks" EntityType="EAModel.BaseBlock" />
        <EntitySet Name="ArchitectureBlocks" EntityType="EAModel.ArchitectureBlock" />
        <EntitySet Name="SolutionBlocks" EntityType="EAModel.SolutionBlock" />
        <EntitySet Name="InterfaceBlocks" EntityType="EAModel.InterfaceBlock" />
        <EntitySet Name="Users" EntityType="EAModel.User" />
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

    auto userOData = new UserODataController();
    odataRouter.registerController("Users", userOData);

    /// Activate CORS and OData routes
    router.any("*", &enableCORS);

    // Demo authentication endpoint used by the Login view.
    router.post("/api/auth/login", &postLogin);
    router.get("/api/notifications", &getNotifications);
    router.get("/api/logs", &getLogs);

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
