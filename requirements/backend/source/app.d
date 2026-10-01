import vibe.d;
import std.algorithm : startsWith;
import std.array : appender;
import std.conv : to;
import std.datetime : Clock;
import std.exception : enforce;
import std.file : exists, readText;
import std.path : buildPath, extension;
import std.string : format, indexOf;
import std.uri : decodeComponent;

struct Project {
  string ID;
  string Name;
  string Description;
}

struct Requirement {
  string ID;
  string Title;
  string Description;
  string Category;
  string Type;
  string ProjectID;
  string ParentBusinessRequirementID;
  string CreatedAt;
  string UpdatedAt;
}

Project[] g_projects;
Requirement[] g_requirements;
size_t g_reqCounter = 1000;

immutable string SERVICE_ROOT = "/odata/v4/RequirementsService";
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
  logInfo("Requirements Management available on http://localhost:8080");
  runEventLoop();
}

void seedData() {
  g_projects = [
    Project("P-100", "Customer Portal", "Digital customer entry point"),
    Project("P-200", "Compliance Hub", "Audit and governance modernization")
  ];

  auto now = timestamp();
  g_requirements = [
    Requirement(
      "REQ-1001",
      "Self-service onboarding",
      "Customers can onboard without call-center interaction",
      "Business",
      "Business",
      "P-100",
      "",
      now,
      now
    ),
    Requirement(
      "REQ-1002",
      "Identity verification workflow",
      "Provide KYC integration via external provider",
      "Solution",
      "Solution",
      "P-100",
      "REQ-1001",
      now,
      now
    ),
    Requirement(
      "REQ-1003",
      "Regulatory reporting requirement",
      "Platform must provide traceable audit reports",
      "Business",
      "Business",
      "P-200",
      "",
      now,
      now
    ),
    Requirement(
      "REQ-1004",
      "Audit event persistence",
      "Persist immutable audit records for every approval",
      "Solution",
      "Solution",
      "P-200",
      "REQ-1003",
      now,
      now
    )
  ];

  g_reqCounter = 1005;
}

void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative == "" || relative == "/") {
    res.contentType = "application/json";
    auto payload = Json.emptyObject;
    payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata");
    auto value = Json.emptyArray;

    auto s1 = Json.emptyObject;
    s1["name"] = Json("Projects");
    s1["kind"] = Json("EntitySet");
    s1["url"] = Json("Projects");
    value ~= s1;

    auto s2 = Json.emptyObject;
    s2["name"] = Json("BusinessRequirements");
    s2["kind"] = Json("EntitySet");
    s2["url"] = Json("BusinessRequirements");
    value ~= s2;

    auto s3 = Json.emptyObject;
    s3["name"] = Json("SolutionRequirements");
    s3["kind"] = Json("EntitySet");
    s3["url"] = Json("SolutionRequirements");
    value ~= s3;

    payload["value"] = value;
    res.writeJsonBody(payload);
    return;
  }

  if (relative == "/$metadata") {
    res.writeBody(getMetadataXml(), cast(int) HTTPStatus.ok, "application/xml");
    return;
  }

  if (relative == "/Projects") {
    writeProjectsCollection(res);
    return;
  }

  if (relative.startsWith("/Projects(")) {
    auto id = parseKey(relative, "Projects");
    writeProjectById(res, id);
    return;
  }

  if (relative == "/Requirements") {
    writeRequirementsCollection(res, "");
    return;
  }

  if (relative.startsWith("/Requirements(")) {
    auto id = parseKey(relative, "Requirements");
    writeRequirementById(res, id, "");
    return;
  }

  if (relative == "/BusinessRequirements") {
    writeRequirementsCollection(res, "Business");
    return;
  }

  if (relative.startsWith("/BusinessRequirements(")) {
    auto id = parseKey(relative, "BusinessRequirements");
    writeRequirementById(res, id, "Business");
    return;
  }

  if (relative == "/SolutionRequirements") {
    writeRequirementsCollection(res, "Solution");
    return;
  }

  if (relative.startsWith("/SolutionRequirements(")) {
    auto id = parseKey(relative, "SolutionRequirements");
    writeRequirementById(res, id, "Solution");
    return;
  }

  writeNotFound(res, "Unknown GET endpoint");
}

void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative == "/Projects") {
    createProject(req, res);
    return;
  }

  if (relative == "/Requirements") {
    createRequirement(req, res, "");
    return;
  }

  if (relative == "/BusinessRequirements") {
    createRequirement(req, res, "Business");
    return;
  }

  if (relative == "/SolutionRequirements") {
    createRequirement(req, res, "Solution");
    return;
  }

  writeNotFound(res, "Unknown POST endpoint");
}

void handlePatch(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative.startsWith("/Projects(")) {
    auto id = parseKey(relative, "Projects");
    updateProject(req, res, id);
    return;
  }

  if (relative.startsWith("/Requirements(")) {
    auto id = parseKey(relative, "Requirements");
    updateRequirement(req, res, id, "");
    return;
  }

  if (relative.startsWith("/BusinessRequirements(")) {
    auto id = parseKey(relative, "BusinessRequirements");
    updateRequirement(req, res, id, "Business");
    return;
  }

  if (relative.startsWith("/SolutionRequirements(")) {
    auto id = parseKey(relative, "SolutionRequirements");
    updateRequirement(req, res, id, "Solution");
    return;
  }

  writeNotFound(res, "Unknown PATCH endpoint");
}

void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative.startsWith("/Projects(")) {
    auto id = parseKey(relative, "Projects");
    deleteProject(res, id);
    return;
  }

  if (relative.startsWith("/Requirements(")) {
    auto id = parseKey(relative, "Requirements");
    deleteRequirement(res, id, "");
    return;
  }

  if (relative.startsWith("/BusinessRequirements(")) {
    auto id = parseKey(relative, "BusinessRequirements");
    deleteRequirement(res, id, "Business");
    return;
  }

  if (relative.startsWith("/SolutionRequirements(")) {
    auto id = parseKey(relative, "SolutionRequirements");
    deleteRequirement(res, id, "Solution");
    return;
  }

  writeNotFound(res, "Unknown DELETE endpoint");
}

void writeProjectsCollection(HTTPServerResponse res) {
  auto value = Json.emptyArray;
  foreach (p; g_projects) {
    value ~= toJson(p);
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
      res.contentType = "application/json";
      res.writeJsonBody(toJson(p));
      return;
    }
  }

  writeNotFound(res, "Project not found");
}

void writeRequirementsCollection(HTTPServerResponse res, string requirementType) {
  auto value = Json.emptyArray;
  foreach (r; g_requirements) {
    if (requirementType.length > 0 && r.Type != requirementType) {
      continue;
    }
    value ~= toJson(r);
  }

  auto payload = Json.emptyObject;
  auto contextSuffix = requirementType == "Business"
    ? "BusinessRequirements"
    : requirementType == "Solution"
      ? "SolutionRequirements"
      : "Requirements";
  payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata#" ~ contextSuffix);
  payload["value"] = value;
  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void writeRequirementById(HTTPServerResponse res, string id, string requirementType) {
  foreach (r; g_requirements) {
    if (r.ID == id) {
      if (requirementType.length > 0 && r.Type != requirementType) {
        break;
      }
      res.contentType = "application/json";
      res.writeJsonBody(toJson(r));
      return;
    }
  }

  writeNotFound(res, "Requirement not found");
}

void createProject(HTTPServerRequest req, HTTPServerResponse res) {
  try {
    auto payload = req.json;
    auto name = requiredString(payload, "Name", "Project name is required");

    Project p;
    p.ID = optionalString(payload, "ID", "PRJ-" ~ Clock.currTime.stdTime.to!string);
    p.Name = name;
    p.Description = optionalString(payload, "Description", "");

    enforce(!projectExists(p.ID), "Project ID already exists");

    g_projects ~= p;

    res.statusCode = HTTPStatus.created;
    res.contentType = "application/json";
    res.writeJsonBody(toJson(p));
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void createRequirement(HTTPServerRequest req, HTTPServerResponse res, string routeType) {
  try {
    auto payload = req.json;

    Requirement r;
    r.ID = optionalString(payload, "ID", nextRequirementId());
    r.Title = requiredString(payload, "Title", "Requirement title is required");
    r.Description = optionalString(payload, "Description", "");
    r.Category = optionalString(payload, "Category", "General");
    r.Type = routeType.length > 0 ? routeType : optionalString(payload, "Type", "Business");
    r.ProjectID = requiredString(payload, "ProjectID", "ProjectID is required");
    r.ParentBusinessRequirementID = optionalString(payload, "ParentBusinessRequirementID", "");
    auto now = timestamp();
    r.CreatedAt = now;
    r.UpdatedAt = now;

    validateRequirement(r);
    enforce(!requirementExists(r.ID), "Requirement ID already exists");

    g_requirements ~= r;

    res.statusCode = HTTPStatus.created;
    res.contentType = "application/json";
    res.writeJsonBody(toJson(r));
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void updateProject(HTTPServerRequest req, HTTPServerResponse res, string id) {
  try {
    auto payload = req.json;

    foreach (ref p; g_projects) {
      if (p.ID == id) {
        if ("Name" in payload) {
          p.Name = payload["Name"].get!string;
        }
        if ("Description" in payload) {
          p.Description = payload["Description"].get!string;
        }

        res.contentType = "application/json";
        res.writeJsonBody(toJson(p));
        return;
      }
    }

    writeNotFound(res, "Project not found");
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void updateRequirement(HTTPServerRequest req, HTTPServerResponse res, string id, string routeType) {
  try {
    auto payload = req.json;

    foreach (ref r; g_requirements) {
      if (r.ID == id) {
        if (routeType.length > 0 && r.Type != routeType) {
          writeNotFound(res, "Requirement not found");
          return;
        }

        if ("Title" in payload) {
          r.Title = payload["Title"].get!string;
        }
        if ("Description" in payload) {
          r.Description = payload["Description"].get!string;
        }
        if ("Category" in payload) {
          r.Category = payload["Category"].get!string;
        }
        if ("Type" in payload && routeType.length == 0) {
          r.Type = payload["Type"].get!string;
        }
        if ("ProjectID" in payload) {
          r.ProjectID = payload["ProjectID"].get!string;
        }
        if ("ParentBusinessRequirementID" in payload) {
          r.ParentBusinessRequirementID = payload["ParentBusinessRequirementID"].get!string;
        }

        if (routeType.length > 0) {
          r.Type = routeType;
        }

        r.UpdatedAt = timestamp();
        validateRequirement(r);

        res.contentType = "application/json";
        res.writeJsonBody(toJson(r));
        return;
      }
    }

    writeNotFound(res, "Requirement not found");
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void deleteProject(HTTPServerResponse res, string id) {
  foreach (r; g_requirements) {
    if (r.ProjectID == id) {
      writeBadRequest(res, "Project still contains requirements");
      return;
    }
  }

  foreach (i, p; g_projects) {
    if (p.ID == id) {
      g_projects = g_projects[0 .. i] ~ g_projects[i + 1 .. $];
      res.statusCode = HTTPStatus.noContent;
      return;
    }
  }

  writeNotFound(res, "Project not found");
}

void deleteRequirement(HTTPServerResponse res, string id, string requirementType) {
  foreach (r; g_requirements) {
    if (r.ParentBusinessRequirementID == id) {
      writeBadRequest(res, "Delete dependent solution requirements first");
      return;
    }
  }

  foreach (i, r; g_requirements) {
    if (r.ID == id) {
      if (requirementType.length > 0 && r.Type != requirementType) {
        break;
      }
      g_requirements = g_requirements[0 .. i] ~ g_requirements[i + 1 .. $];
      res.statusCode = HTTPStatus.noContent;
      return;
    }
  }

  writeNotFound(res, "Requirement not found");
}

void validateRequirement(const Requirement r) {
  enforce(r.Type == "Business" || r.Type == "Solution", "Type must be Business or Solution");
  enforce(projectExists(r.ProjectID), "ProjectID does not exist");

  if (r.Type == "Business") {
    enforce(r.ParentBusinessRequirementID.length == 0, "Business requirements cannot reference ParentBusinessRequirementID");
    return;
  }

  enforce(r.ParentBusinessRequirementID.length > 0, "Solution requirements must reference ParentBusinessRequirementID");
  auto parent = findRequirement(r.ParentBusinessRequirementID);
  enforce(parent !is null && parent.Type == "Business", "ParentBusinessRequirementID must reference a Business requirement");
  enforce(parent.ProjectID == r.ProjectID, "Solution requirement must belong to the same project as its parent business requirement");
}

bool projectExists(string id) {
  foreach (p; g_projects) {
    if (p.ID == id) {
      return true;
    }
  }
  return false;
}

bool requirementExists(string id) {
  foreach (r; g_requirements) {
    if (r.ID == id) {
      return true;
    }
  }
  return false;
}

bool requirementTypeIs(string id, string requirementType) {
  foreach (r; g_requirements) {
    if (r.ID == id) {
      return r.Type == requirementType;
    }
  }
  return false;
}

const(Requirement)* findRequirement(string id) {
  foreach (ref r; g_requirements) {
    if (r.ID == id) {
      return &r;
    }
  }
  return null;
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

string nextRequirementId() {
  auto id = format("REQ-%s", g_reqCounter);
  g_reqCounter++;
  return id;
}

string timestamp() {
  return Clock.currTime.toISOExtString();
}

string serviceRelativePath(HTTPServerRequest req) {
  auto full = req.requestPath.to!string;
  if (!full.startsWith(SERVICE_ROOT)) {
    return "";
  }

  return full[SERVICE_ROOT.length .. $];
}

string parseKey(string relative, string entityName) {
  auto prefix = "/" ~ entityName ~ "('";
  auto suffix = "')";

  enforce(relative.startsWith(prefix) && relative.endsWith(suffix), "Invalid key syntax");
  auto raw = relative[prefix.length .. $ - suffix.length];
  return decodeComponent(raw);
}

Json toJson(const Project p) {
  auto j = Json.emptyObject;
  j["ID"] = Json(p.ID);
  j["Name"] = Json(p.Name);
  j["Description"] = Json(p.Description);
  return j;
}

Json toJson(const Requirement r) {
  auto j = Json.emptyObject;
  j["ID"] = Json(r.ID);
  j["Title"] = Json(r.Title);
  j["Description"] = Json(r.Description);
  j["Category"] = Json(r.Category);
  j["Type"] = Json(r.Type);
  j["ProjectID"] = Json(r.ProjectID);
  j["ParentBusinessRequirementID"] = Json(r.ParentBusinessRequirementID);
  j["CreatedAt"] = Json(r.CreatedAt);
  j["UpdatedAt"] = Json(r.UpdatedAt);
  return j;
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
    res.statusCode = HTTPStatus.notFound;
    res.writeBody("File not found", cast(int) HTTPStatus.notFound, "text/plain");
    return;
  }

  auto mime = mimeTypeFor(diskPath);
  res.writeBody(readText(diskPath), cast(int) HTTPStatus.ok, mime);
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
    <Schema Namespace="RequirementsModel" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Project">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String"/>
        <NavigationProperty Name="Requirements" Type="Collection(RequirementsModel.Requirement)" Partner="Project"/>
      </EntityType>

      <EntityType Name="Requirement">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Title" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String"/>
        <Property Name="Category" Type="Edm.String"/>
        <Property Name="Type" Type="Edm.String" Nullable="false"/>
        <Property Name="ProjectID" Type="Edm.String" Nullable="false"/>
        <Property Name="ParentBusinessRequirementID" Type="Edm.String"/>
        <Property Name="CreatedAt" Type="Edm.String"/>
        <Property Name="UpdatedAt" Type="Edm.String"/>
        <NavigationProperty Name="Project" Type="RequirementsModel.Project" Partner="Requirements">
          <ReferentialConstraint Property="ProjectID" ReferencedProperty="ID"/>
        </NavigationProperty>
      </EntityType>

      <EntityContainer Name="Container">
        <EntitySet Name="Projects" EntityType="RequirementsModel.Project">
          <NavigationPropertyBinding Path="Requirements" Target="Requirements"/>
        </EntitySet>
        <EntitySet Name="BusinessRequirements" EntityType="RequirementsModel.Requirement"/>
        <EntitySet Name="SolutionRequirements" EntityType="RequirementsModel.Requirement"/>
        <EntitySet Name="Requirements" EntityType="RequirementsModel.Requirement">
          <NavigationPropertyBinding Path="Project" Target="Projects"/>
        </EntitySet>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
}
