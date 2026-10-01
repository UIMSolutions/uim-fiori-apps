import vibe.d;
import std.conv : to;
import std.datetime : Clock;
import std.exception : enforce;
import std.file : exists, readText;
import std.path : buildPath, extension;
import std.string : format, startsWith;

struct Drawing {
  string ID;
  string Name;
  string Project;
  string DrawingType;
  string Description;
  string DataJson;
  string CreatedAt;
  string UpdatedAt;
}

Drawing[] g_drawings;
size_t g_drawingCounter = 2000;

immutable string SERVICE_ROOT = "/odata/v4/CadService";
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
  logInfo("CAD manager running on http://localhost:8080");
  runEventLoop();
}

void seedData() {
  auto now = timestamp();
  auto sample = Json.emptyObject;
  sample["strokes"] = Json.emptyArray;

  g_drawings = [
    Drawing(
      "DRW-2001",
      "Factory Floor Plan",
      "Plant-Revamp",
      "Architecture",
      "Main hall and emergency exits",
      sample.toString(),
      now,
      now
    ),
    Drawing(
      "DRW-2002",
      "Cooling Unit Scheme",
      "Line-B",
      "Mechanical",
      "Layout for cooling units",
      sample.toString(),
      now,
      now
    )
  ];
  g_drawingCounter = 2003;
}

void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);

  if (relative == "" || relative == "/") {
    auto payload = Json.emptyObject;
    payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata");
    auto value = Json.emptyArray;

    auto item = Json.emptyObject;
    item["name"] = Json("Drawings");
    item["kind"] = Json("EntitySet");
    item["url"] = Json("Drawings");
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

  if (relative == "/Drawings") {
    writeDrawings(res);
    return;
  }

  if (relative.startsWith("/Drawings(")) {
    writeDrawingById(res, parseKey(relative, "Drawings"));
    return;
  }

  writeNotFound(res, "Unknown endpoint");
}

void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (relative != "/Drawings") {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  try {
    auto payload = req.json;

    Drawing d;
    d.ID = optionalString(payload, "ID", nextDrawingId());
    d.Name = requiredString(payload, "Name", "Name is required");
    d.Project = requiredString(payload, "Project", "Project is required");
    d.DrawingType = requiredString(payload, "DrawingType", "DrawingType is required");
    d.Description = optionalString(payload, "Description", "");
    d.DataJson = optionalString(payload, "DataJson", "{\"strokes\":[]}");
    auto now = timestamp();
    d.CreatedAt = now;
    d.UpdatedAt = now;

    enforce(!drawingExists(d.ID), "ID already exists");
    g_drawings ~= d;

    res.statusCode = HTTPStatus.created;
    res.contentType = "application/json";
    res.writeJsonBody(toJson(d));
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void handlePatch(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (!relative.startsWith("/Drawings(")) {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  auto id = parseKey(relative, "Drawings");

  try {
    auto payload = req.json;
    foreach (ref d; g_drawings) {
      if (d.ID == id) {
        if ("Name" in payload) d.Name = payload["Name"].get!string;
        if ("Project" in payload) d.Project = payload["Project"].get!string;
        if ("DrawingType" in payload) d.DrawingType = payload["DrawingType"].get!string;
        if ("Description" in payload) d.Description = payload["Description"].get!string;
        if ("DataJson" in payload) d.DataJson = payload["DataJson"].get!string;
        d.UpdatedAt = timestamp();

        res.contentType = "application/json";
        res.writeJsonBody(toJson(d));
        return;
      }
    }

    writeNotFound(res, "Drawing not found");
  } catch (Exception ex) {
    writeBadRequest(res, ex.msg);
  }
}

void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
  auto relative = serviceRelativePath(req);
  if (!relative.startsWith("/Drawings(")) {
    writeNotFound(res, "Unknown endpoint");
    return;
  }

  auto id = parseKey(relative, "Drawings");
  foreach (i, d; g_drawings) {
    if (d.ID == id) {
      g_drawings = g_drawings[0 .. i] ~ g_drawings[i + 1 .. $];
      res.statusCode = HTTPStatus.noContent;
      return;
    }
  }

  writeNotFound(res, "Drawing not found");
}

void writeDrawings(HTTPServerResponse res) {
  auto value = Json.emptyArray;
  foreach (d; g_drawings) {
    value ~= toJson(d);
  }

  auto payload = Json.emptyObject;
  payload["@odata.context"] = Json(SERVICE_ROOT ~ "/$metadata#Drawings");
  payload["value"] = value;

  res.contentType = "application/json";
  res.writeJsonBody(payload);
}

void writeDrawingById(HTTPServerResponse res, string id) {
  foreach (d; g_drawings) {
    if (d.ID == id) {
      res.contentType = "application/json";
      res.writeJsonBody(toJson(d));
      return;
    }
  }

  writeNotFound(res, "Drawing not found");
}

Json toJson(const Drawing d) {
  auto j = Json.emptyObject;
  j["ID"] = Json(d.ID);
  j["Name"] = Json(d.Name);
  j["Project"] = Json(d.Project);
  j["DrawingType"] = Json(d.DrawingType);
  j["Description"] = Json(d.Description);
  j["DataJson"] = Json(d.DataJson);
  j["CreatedAt"] = Json(d.CreatedAt);
  j["UpdatedAt"] = Json(d.UpdatedAt);
  return j;
}

bool drawingExists(string id) {
  foreach (d; g_drawings) {
    if (d.ID == id) {
      return true;
    }
  }
  return false;
}

string nextDrawingId() {
  auto id = format("DRW-%s", g_drawingCounter);
  g_drawingCounter++;
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
    <Schema Namespace="CadModel" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Drawing">
        <Key>
          <PropertyRef Name="ID"/>
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Project" Type="Edm.String" Nullable="false"/>
        <Property Name="DrawingType" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String"/>
        <Property Name="DataJson" Type="Edm.String"/>
        <Property Name="CreatedAt" Type="Edm.String"/>
        <Property Name="UpdatedAt" Type="Edm.String"/>
      </EntityType>

      <EntityContainer Name="Container">
        <EntitySet Name="Drawings" EntityType="CadModel.Drawing"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
}
