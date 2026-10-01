import vibe.d;
import std.conv : to;
import std.datetime : Clock;
import std.exception : enforce;
import std.file : exists, readText;
import std.path : buildPath, extension;
import std.string : format, startsWith;

struct Diagram {
  string ID;
  string Name;
  string Project;
  string DiagramType;
  string Description;
  string DataJson;
  string CreatedAt;
  string UpdatedAt;
}

struct ProjectSummary {
  string ID;
  string Name;
  string Owner;
  string UpdatedAt;
}

Diagram[] g_diagrams;
ProjectSummary[] g_projects;
size_t g_diagramCounter = 3000;

immutable string SERVICE_ROOT = "/odata/v4/UmlService";
immutable string WEB_ROOT = "public/webapp";

void main() {
  seedData();

  auto settings = new HTTPServerSettings();
  settings.bindAddresses = ["0.0.0.0"];
  settings.port = 8080;

  auto router = new URLRouter();
  router.get(SERVICE_ROOT ~ "/*", &handleGet);
  router.post(SERVICE_ROOT ~ "/*", &handlePost);
  router.patch(SERVICE_ROOT ~ "/*", &handlePatch);
  router.delete_(SERVICE_ROOT ~ "/*", &handleDelete);
  router.get("/*", &serveStaticAsset);

  listenHTTP(settings, router);
  logInfo("UML manager running on http://localhost:8080");
  runEventLoop();
}

void seedData() {
  auto now = timestamp();
  auto sample = Json.emptyObject;
  sample["shapes"] = Json.emptyArray;

  g_diagrams = [
    Diagram(
      "UML-3001",
      "Order Domain Class Diagram",
      "Commerce-Core",
      "Class",
      "Entities and relationships for order domain",
      sample.toString(),
      now,
      now
    ),
    Diagram(
      "UML-3002",
      "Payment Flow Sequence",
      "Payments",
      "Sequence",
      "Happy path for payment authorization",
      sample.toString(),
      now,
      now
    )
  ];
  g_diagramCounter = 3003;

  g_projects = [
    ProjectSummary("PRJ-100", "Commerce-Core", "Domain Team", now),
    ProjectSummary("PRJ-101", "Payments", "Finance Squad", now),
    ProjectSummary("PRJ-102", "Onboarding", "Platform Crew", now)
  ];
}

void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative == "" || relative == "/") {
    auto payload = Json.emptyObject;
    payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata");
    auto value = Json.emptyArray;

    auto item = Json.emptyObject;
    item["name"] = Json("Diagrams");
    item["kind"] = Json("EntitySet");
    item["url"] = Json("Diagrams");
    value ~= item;

    item = Json.emptyObject;
    item["name"] = Json("Projects");
    item["kind"] = Json("EntitySet");
    item["url"] = Json("Projects");
    value ~= item;

    item = Json.emptyObject;
    item["name"] = Json("DashboardStats");
    item["kind"] = Json("EntitySet");
    item["url"] = Json("DashboardStats");
    value ~= item;

    payload["value"] = value;
    res.contentType = "application/json";
    res.writeJsonBody(payload);
    return;
  }

  if (relative == "/$metadata") {
    res.writeBody(getMetadataXml(), cast(int) HTTPStatus.ok, "application/xml");
    return;
  }

  if (relative == "/Diagrams") {
    writeDiagrams(res);
    return;
  }

  if (relative == "/Projects") {
    writeProjects(res);
    return;
  }

  if (relative == "/DashboardStats") {
    writeDashboardStats(res);
    return;
  }

  if (relative.startsWith("/Diagrams(")) {
    writeDiagramById(res, parseKey(relative, "Diagrams"));
    return;
  }

  if (relative.startsWith("/Projects(")) {
    writeProjectById(res, parseKey(relative, "Projects"));
    return;
  }

  writeNotFound(res, "Unknown endpoint");
}

void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (relative != "/Diagrams") {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  try {
    auto payload = req.json;

    Diagram d;
    d.ID = optionalString(payload, "ID", nextDiagramId());
    d.Name = requiredString(payload, "Name", "Name is required");
    d.Project = requiredString(payload, "Project", "Project is required");
    d.DiagramType = requiredString(payload, "DiagramType", "DiagramType is required");
    d.Description = optionalString(payload, "Description", "");
    d.DataJson = optionalString(payload, "DataJson", "{\"shapes\":[]}");
    auto now = timestamp();
    d.CreatedAt = now;
    d.UpdatedAt = now;

    enforce(!diagramExists(d.ID), "ID already exists");
    g_diagrams ~= d;
    touchProjectSummary(d.Project);

    res.statusCode = HTTPStatus.created;
    res.contentType = "application/json";
    res.writeJsonBody(toJson(d));
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void handlePatch(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (!relative.startsWith("/Diagrams(")) {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  auto id = parseKey(relative, "Diagrams");

  try {
    auto payload = req.json;
    foreach (ref d; g_diagrams) {
      if (d.ID == id) {
        auto previousProject = d.Project;
        if ("Name" in payload) d.Name = payload["Name"].get!string;
        if ("Project" in payload) d.Project = payload["Project"].get!string;
        if ("DiagramType" in payload) d.DiagramType = payload["DiagramType"].get!string;
        if ("Description" in payload) d.Description = payload["Description"].get!string;
        if ("DataJson" in payload) d.DataJson = payload["DataJson"].get!string;
        d.UpdatedAt = timestamp();
        touchProjectSummary(previousProject);
        touchProjectSummary(d.Project);

        res.contentType = "application/json";
        res.writeJsonBody(toJson(d));
        return;
      }
    }

    writeNotFound(res, "Diagram not found");
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (!relative.startsWith("/Diagrams(")) {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  auto id = parseKey(relative, "Diagrams");
  foreach (i, d; g_diagrams) {
    if (d.ID == id) {
      g_diagrams = g_diagrams[0 .. i] ~ g_diagrams[i + 1 .. $];
      res.statusCode = HTTPStatus.noContent;
      return;
    }
  }

  writeNotFound(res, "Diagram not found");
}

void writeDiagrams(HTTPServerResponse res) {
  auto value = Json.emptyArray;
  foreach (d; g_diagrams) {
    value ~= toJson(d);
  }

  auto payload = Json.emptyObject;
  payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata#Diagrams");
  payload["value"] = value;

  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void writeDiagramById(HTTPServerResponse res, string id) {
  foreach (d; g_diagrams) {
    if (d.ID == id) {
      res.contentType = "application/json";
      res.writeJsonBody(toJson(d));
      return;
    }
  }

  writeNotFound(res, "Diagram not found");
}

void writeProjects(HTTPServerResponse res) {
  auto value = Json.emptyArray;

  foreach (p; g_projects) {
    auto projectJson = Json.emptyObject;
    projectJson["ID"] = Json(p.ID);
    projectJson["Name"] = Json(p.Name);
    projectJson["Owner"] = Json(p.Owner);
    projectJson["DiagramCount"] = Json(cast(long) projectDiagramCount(p.Name));
    projectJson["UpdatedAt"] = Json(p.UpdatedAt);
    value ~= projectJson;
  }

  auto payload = Json.emptyObject;
  payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata#Projects");
  payload["value"] = value;

  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void writeProjectById(HTTPServerResponse res, string id) {
  foreach (p; g_projects) {
    if (p.ID == id) {
      auto payload = Json.emptyObject;
      payload["ID"] = Json(p.ID);
      payload["Name"] = Json(p.Name);
      payload["Owner"] = Json(p.Owner);
      payload["DiagramCount"] = Json(cast(long) projectDiagramCount(p.Name));
      payload["UpdatedAt"] = Json(p.UpdatedAt);
      res.contentType = "application/json";
      res.writeJsonBody(payload);
      return;
    }
  }

  writeNotFound(res, "Project not found");
}

void writeDashboardStats(HTTPServerResponse res) {
  auto value = Json.emptyArray;
  auto stat = Json.emptyObject;
  stat["ID"] = Json("CURRENT");
  stat["TotalDiagrams"] = Json(cast(long) g_diagrams.length);
  stat["TotalProjects"] = Json(cast(long) g_projects.length);
  stat["LastUpdated"] = Json(lastUpdatedTimestamp());
  value ~= stat;

  auto payload = Json.emptyObject;
  payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata#DashboardStats");
  payload["value"] = value;

  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

Json toJson(const Diagram d) {
  auto j = Json.emptyObject;
  j["ID"] = Json(d.ID);
  j["Name"] = Json(d.Name);
  j["Project"] = Json(d.Project);
  j["DiagramType"] = Json(d.DiagramType);
  j["Description"] = Json(d.Description);
  j["DataJson"] = Json(d.DataJson);
  j["CreatedAt"] = Json(d.CreatedAt);
  j["UpdatedAt"] = Json(d.UpdatedAt);
  return j;
}

bool diagramExists(string id) {
  foreach (d; g_diagrams) {
    if (d.ID == id) {
      return true;
    }
  }
  return false;
}

size_t projectDiagramCount(string projectName) {
  size_t count = 0;
  foreach (d; g_diagrams) {
    if (d.Project == projectName) {
      count++;
    }
  }
  return count;
}

string lastUpdatedTimestamp() {
  string last = "";
  foreach (d; g_diagrams) {
    if (d.UpdatedAt > last) {
      last = d.UpdatedAt;
    }
  }
  return last.length > 0 ? last : timestamp();
}

void touchProjectSummary(string projectName) {
  if (projectName.length == 0) {
    return;
  }

  foreach (ref p; g_projects) {
    if (p.Name == projectName) {
      p.UpdatedAt = timestamp();
      return;
    }
  }

  auto id = format("PRJ-%s", 200 + g_projects.length);
  g_projects ~= ProjectSummary(id, projectName, "Solution Team", timestamp());
}

string nextDiagramId() {
  auto id = format("UML-%s", g_diagramCounter);
  g_diagramCounter++;
  return id;
}

string timestamp() {
  return Clock.currTime.toISOExtString();
}

string optionalString(const Json payload, string key, string fallback) {
  if (key in payload) {
    return payload[key].get!string;
  }
  return fallback;
}

string requiredString(const Json payload, string key, string message) {
  if (!(key in payload)) {
    enforce(false, message);
  }

  auto value = payload[key].get!string;
  enforce(value.length > 0, message);
  return value;
}

string serviceRelativePath(HTTPServerRequest req) {
  auto path = req.requestPath.to!string;
  if (!path.startsWith(SERVICE_ROOT)) {
    return "";
  }

  return path[SERVICE_ROOT.length .. $];
}

string parseKey(string relative, string entityName) {
  auto prefix = "/" ~ entityName ~ "('";
  auto suffix = "')";
  enforce(relative.startsWith(prefix) && relative.endsWith(suffix), "Invalid key syntax");
  return relative[prefix.length .. $ - suffix.length];
}

void writeNotFound(HTTPServerResponse res, string message) {
  auto payload = Json.emptyObject;
  payload["error"] = Json(message);
  res.statusCode = HTTPStatus.notFound;
  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void writeBadRequest(HTTPServerResponse res, string message) {
  auto payload = Json.emptyObject;
  payload["error"] = Json(message);
  res.statusCode = HTTPStatus.badRequest;
  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void serveStaticAsset(HTTPServerRequest req, HTTPServerResponse res) {
  auto requestPath = req.requestPath.to!string;
  if (requestPath == "/") {
    requestPath = "/index.html";
  }

  if (requestPath.startsWith(SERVICE_ROOT)) {
    writeNotFound(res, "Route not found");
    return;
  }

  auto diskPath = buildPath(WEB_ROOT, requestPath[1 .. $]);
  if (!exists(diskPath)) {
    res.writeBody("File not found", cast(int) HTTPStatus.notFound, "text/plain");
    return;
  }

  res.writeBody(readText(diskPath), cast(int) HTTPStatus.ok, mimeTypeFor(diskPath));
}

string mimeTypeFor(string path) {
  switch (extension(path)) {
    case ".html":
      return "text/html; charset=utf-8";
    case ".js":
      return "application/javascript; charset=utf-8";
    case ".xml":
      return "application/xml; charset=utf-8";
    case ".json":
      return "application/json; charset=utf-8";
    case ".css":
      return "text/css; charset=utf-8";
    case ".properties":
      return "text/plain; charset=utf-8";
    default:
      return "text/plain; charset=utf-8";
  }
}

string getMetadataXml() {
  return `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="UmlModel" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Diagram">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Project" Type="Edm.String" Nullable="false"/>
        <Property Name="DiagramType" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String"/>
        <Property Name="DataJson" Type="Edm.String"/>
        <Property Name="CreatedAt" Type="Edm.String"/>
        <Property Name="UpdatedAt" Type="Edm.String"/>
      </EntityType>

      <EntityType Name="Project">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Owner" Type="Edm.String" Nullable="false"/>
        <Property Name="DiagramCount" Type="Edm.Int64" Nullable="false"/>
        <Property Name="UpdatedAt" Type="Edm.String"/>
      </EntityType>

      <EntityType Name="DashboardStat">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="TotalDiagrams" Type="Edm.Int64" Nullable="false"/>
        <Property Name="TotalProjects" Type="Edm.Int64" Nullable="false"/>
        <Property Name="LastUpdated" Type="Edm.String"/>
      </EntityType>

      <EntityContainer Name="Container">
        <EntitySet Name="Diagrams" EntityType="UmlModel.Diagram"/>
        <EntitySet Name="Projects" EntityType="UmlModel.Project"/>
        <EntitySet Name="DashboardStats" EntityType="UmlModel.DashboardStat"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
}
