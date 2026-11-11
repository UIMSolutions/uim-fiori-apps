/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.service;

/// Transport independent OData v4 request processing.
///
/// `ODataService.handle` maps an `ODataRequest` to an `ODataResult`. The vibe.d routes and the
/// $batch processor are thin wrappers around it, which also makes the protocol unit-testable.
///
/// Supported resource paths (relative to the service root):
///   ""                         service document
///   $metadata                  CSDL XML
///   Set                        GET (query options), POST
///   Set/$count                 GET (honours $filter / $search)
///   Set('key') | Set(ID='key') GET, PATCH, PUT, DELETE
///   Set('key')/Property        GET
import std.algorithm : canFind, startsWith;
import std.conv : to;
import std.string : indexOf, strip, toLower, toUpper;

import vibe.data.json : Json, JSONException;

import uim.fiori_blocks.application;
import uim.fiori_blocks.domain.exceptions;
import uim.fiori_blocks.infrastructure.logging;
import uim.fiori_blocks.presentation.odata.edm;
import uim.fiori_blocks.presentation.odata.errors;
import uim.fiori_blocks.presentation.odata.parser;

@safe:

enum jsonContentType = "application/json;odata.metadata=minimal;charset=utf-8";

struct ODataRequest {
  string method = "GET";
  string path; /// resource path relative to the service root, percent-decoded
  string[string] query; /// decoded query options
  string[string] headers; /// lower-case header names
  Json body; /// request payload (undefined if none)
}

struct ODataResult {
  int status = 200;
  string[string] headers;
  string contentType;
  Json json; /// JSON payload, undefined if none
  string text; /// non-JSON payload ($metadata, $count)

  bool hasJson() const {
    return json.type != Json.Type.undefined;
  }

  /// Serialized payload.
  string payload() const @trusted {
    return hasJson ? toODataJson(cast() json) : text;
  }

  bool isError() const {
    return status >= 400;
  }
}

/// Serializes Json with OData member order: control information ("@odata.*") first, then "ID",
/// then the remaining members alphabetically (vibe.d Json objects are unordered).
string toODataJson(Json value) @trusted {
  import std.algorithm : sort;
  import std.array : appender;

  auto output = appender!string;
  void write(Json v) {
    switch (v.type) {
    case Json.Type.object:
      string[] keys;
      foreach (string key, _; v.byKeyValue)
        keys ~= key;
      keys.sort!((a, b) {
        int rank(string k) {
          return k.length && k[0] == '@' ? 0 : k == "ID" ? 1 : 2;
        }

        return rank(a) != rank(b) ? rank(a) < rank(b) : a < b;
      });
      output ~= '{';
      foreach (i, key; keys) {
        if (i)
          output ~= ',';
        output ~= Json(key).toString;
        output ~= ':';
        write(v[key]);
      }
      output ~= '}';
      break;
    case Json.Type.array:
      output ~= '[';
      foreach (i, item; v.get!(Json[])) {
        if (i)
          output ~= ',';
        write(item);
      }
      output ~= ']';
      break;
    default:
      output ~= v.toString;
    }
  }

  write(value);
  return output.data;
}

///
unittest {
  auto json = Json(["value": Json([Json(["Name": Json("x"), "ID": Json("1")])]), "@odata.context": Json("c")]);
  assert(toODataJson(json) == `{"@odata.context":"c","value":[{"ID":"1","Name":"x"}]}`);
}

/// Parsed resource path.
struct ResourcePath {
  string entitySet;
  bool hasKey;
  string key;
  string property; /// property name or "$count"
}

class ODataService {
  private ServiceCatalog _catalog;
  private string _serviceRoot;
  private string _namespace;
  private string _container;
  private string _metadata;

  this(ServiceCatalog catalog, string serviceRoot = "/odata/v4/", string namespace = "EAModel", string container = "EAService") {
    _catalog = catalog;
    _serviceRoot = serviceRoot.length && serviceRoot[$ - 1] == '/' ? serviceRoot : serviceRoot ~ "/";
    _namespace = namespace;
    _container = container;
    _metadata = generateMetadata(catalog, namespace, container);
  }

  string serviceRoot() const {
    return _serviceRoot;
  }

  string metadata() const {
    return _metadata;
  }

  ServiceCatalog catalog() {
    return _catalog;
  }

  /// Processes a single (non-batch) request. Never throws: errors become OData error responses.
  ODataResult handle(ODataRequest request) {
    try {
      return dispatch(request);
    } catch (ODataException e) {
      return errorResult(e.status, e.code, e.msg);
    } catch (EntityNotFoundException e) {
      return errorResult(404, "NotFound", e.msg);
    } catch (ValidationException e) {
      return errorResult(400, "ValidationFailed", e.msg);
    } catch (ConflictException e) {
      return errorResult(409, "Conflict", e.msg);
    } catch (QueryException e) {
      return errorResult(400, "BadRequest", e.msg);
    } catch (JSONException e) {
      return errorResult(400, "InvalidJson", e.msg);
    } catch (Exception e) {
      logError("OData %s %s failed: %s", request.method, request.path, e.msg);
      return errorResult(500, "InternalError", e.msg);
    }
  }

  private ODataResult dispatch(ODataRequest request) {
    auto method = request.method.toUpper;
    auto path = request.path.strip;
    while (path.startsWith("/"))
      path = path[1 .. $];
    while (path.length && path[$ - 1] == '/')
      path = path[0 .. $ - 1];

    if (path.length == 0) {
      requireMethod(method, ["GET", "HEAD"], path);
      return method == "HEAD" ? ODataResult(200) : jsonResult(200, serviceDocument(_catalog, _serviceRoot));
    }
    if (path == "$metadata") {
      requireMethod(method, ["GET", "HEAD"], path);
      ODataResult result;
      result.contentType = "application/xml";
      result.text = method == "HEAD" ? "" : _metadata;
      return result;
    }
    if (path == "$batch")
      throw badRequest("$batch must be sent as POST with multipart/mixed or application/json to the service root");

    auto resource = parseResourcePath(path);
    auto set = _catalog.find(resource.entitySet);
    if (set is null)
      throw notFound("Entity set '" ~ resource.entitySet ~ "' does not exist");

    if (!resource.hasKey) {
      if (resource.property == "$count") {
        requireMethod(method, ["GET"], path);
        auto spec = parseQueryOptions(request.query);
        spec.top = -1;
        spec.skip = 0;
        ODataResult result;
        result.contentType = "text/plain";
        result.text = set.query(spec).total.to!string;
        return result;
      }
      if (resource.property.length)
        throw notFound("Resource '" ~ path ~ "' does not exist");

      switch (method) {
      case "GET":
        return readCollection(set, request);
      case "POST":
        auto created = set.create(requireBody(request));
        auto result = entityResult(201, set, created);
        result.headers["Location"] = _serviceRoot ~ entityPath(set.name, created["ID"].get!string);
        return result;
      default:
        throw methodNotAllowed(method, path);
      }
    }

    if (resource.property.length) {
      requireMethod(method, ["GET"], path);
      auto entity = set.get(resource.key);
      auto value = resource.property in entity;
      if (value is null)
        throw notFound("Property '" ~ resource.property ~ "' does not exist");
      return jsonResult(200, Json([
        "@odata.context": Json(_serviceRoot ~ "$metadata#" ~ entityPath(set.name, resource.key) ~ "/" ~ resource.property),
        "value": *value
      ]));
    }

    switch (method) {
    case "GET":
      auto entity = set.get(resource.key);
      auto spec = parseQueryOptions(request.query);
      if (spec.select.length)
        entity = project(entity, spec.select, set.keyProperty);
      return entityResult(200, set, entity);
    case "PATCH", "MERGE":
      return changed(request, set, set.patch(resource.key, requireBody(request)));
    case "PUT":
      return changed(request, set, set.replace(resource.key, requireBody(request)));
    case "DELETE":
      set.remove(resource.key);
      return ODataResult(204);
    default:
      throw methodNotAllowed(method, path);
    }
  }

  private ODataResult readCollection(IEntitySetService set, ODataRequest request) {
    auto spec = parseQueryOptions(request.query);
    auto result = set.query(spec);
    auto body = Json.emptyObject;
    body["@odata.context"] = _serviceRoot ~ "$metadata#" ~ set.name;
    if (spec.count)
      body["@odata.count"] = result.total;
    body["value"] = Json(result.items);
    return jsonResult(200, body);
  }

  private ODataResult changed(ODataRequest request, IEntitySetService set, Json entity) {
    auto prefer = "prefer" in request.headers;
    if (prefer !is null && (*prefer).toLower.canFind("return=minimal"))
      return ODataResult(204);
    return entityResult(200, set, entity);
  }

  private ODataResult entityResult(int status, IEntitySetService set, Json entity) {
    auto body = Json.emptyObject;
    body["@odata.context"] = _serviceRoot ~ "$metadata#" ~ set.name ~ "/$entity";
    foreach (string name, value; entity.byKeyValue)
      body[name] = value;
    return jsonResult(status, body);
  }

  private static Json requireBody(ODataRequest request) {
    if (request.body.type != Json.Type.object)
      throw badRequest("Request body must be a JSON object");
    return request.body;
  }

  private static void requireMethod(string method, string[] allowed, string path) {
    if (!allowed.canFind(method))
      throw methodNotAllowed(method, path);
  }
}

ODataResult jsonResult(int status, Json body) {
  ODataResult result;
  result.status = status;
  result.contentType = jsonContentType;
  result.json = body;
  return result;
}

ODataResult errorResult(int status, string code, string message) {
  return jsonResult(status, Json([
    "error": Json(["code": Json(code), "message": Json(message)])
  ]));
}

/// "Set('key')" with OData quote escaping.
string entityPath(string set, string key) pure {
  import std.array : replace;

  return set ~ "('" ~ key.replace("'", "''") ~ "')";
}

/// Splits "Set('a''b')/Prop" into its parts.
ResourcePath parseResourcePath(string path) {
  ResourcePath result;
  auto paren = path.indexOf('(');
  auto slash = path.indexOf('/');

  if (paren < 0 || (slash >= 0 && slash < paren)) {
    if (slash < 0) {
      result.entitySet = path;
    } else {
      result.entitySet = path[0 .. slash];
      result.property = path[slash + 1 .. $];
    }
    return result;
  }

  result.entitySet = path[0 .. paren];
  // find the closing parenthesis outside of quotes
  size_t i = paren + 1;
  bool quoted;
  for (; i < path.length; i++) {
    if (path[i] == '\'')
      quoted = !quoted;
    else if (path[i] == ')' && !quoted)
      break;
  }
  if (i >= path.length)
    throw badRequest("Missing ')' in resource path '" ~ path ~ "'");

  auto keyText = path[paren + 1 .. i].strip;
  // named key: ID='x'
  auto eq = keyText.indexOf('=');
  if (eq > 0 && !keyText[0 .. eq].canFind('\''))
    keyText = keyText[eq + 1 .. $].strip;
  result.key = unquoteKey(keyText);
  result.hasKey = true;

  auto rest = path[i + 1 .. $];
  if (rest.length) {
    if (rest[0] != '/')
      throw badRequest("Invalid resource path '" ~ path ~ "'");
    result.property = rest[1 .. $];
    if (result.property.canFind('/'))
      throw notFound("Nested property paths are not supported: '" ~ path ~ "'");
  }
  return result;
}

private string unquoteKey(string key) {
  import std.array : replace;

  if (key.length >= 2 && key[0] == '\'' && key[$ - 1] == '\'')
    return key[1 .. $ - 1].replace("''", "'");
  if (key.length == 0)
    throw badRequest("Empty key");
  return key;
}

///
unittest {
  auto p = parseResourcePath("ArchitectureBlocks('AB-01')");
  assert(p.entitySet == "ArchitectureBlocks" && p.hasKey && p.key == "AB-01" && p.property == "");
  p = parseResourcePath("Users(ID='O''Neil')/Email");
  assert(p.key == "O'Neil" && p.property == "Email");
  p = parseResourcePath("Users/$count");
  assert(p.entitySet == "Users" && !p.hasKey && p.property == "$count");
  p = parseResourcePath("Things('a)b')");
  assert(p.key == "a)b");
  assert(entityPath("Users", "O'Neil") == "Users('O''Neil')");
}
