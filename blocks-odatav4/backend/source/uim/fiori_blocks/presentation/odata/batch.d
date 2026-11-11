/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.batch;

/// OData v4 $batch processing (as used by the SAPUI5 v4 ODataModel).
///
/// - multipart/mixed batches with nested changesets (atomic: all or nothing)
/// - JSON batches (`{"requests": [...]}`) with atomicity groups
/// - Content-ID references ("$1") to entities created earlier in the same changeset
import std.algorithm : canFind, startsWith;
import std.array : appender, replace, split;
import std.conv : to;
import std.string : indexOf, lineSplitter, strip, toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json, parseJsonString;
import vibe.http.status : httpStatusText;

import uim.fiori_blocks.presentation.odata.errors;
import uim.fiori_blocks.presentation.odata.service;
import uim.fiori_blocks.presentation.odata.url;

@safe:

/// One operation of a batch.
struct BatchOperation {
  string contentId;
  string method;
  string url;
  string[string] headers;
  Json body;
}

/// A batch item: a single operation or a changeset (list of operations).
struct BatchItem {
  bool isChangeset;
  BatchOperation operation;
  BatchOperation[] changeset;
}

/// Processes a multipart/mixed $batch request body.
ODataResult processMultipartBatch(ODataService service, string contentType, string body) {
  auto boundary = boundaryOf(contentType);
  if (boundary.length == 0)
    return errorResult(400, "BadRequest", "Missing boundary in multipart/mixed Content-Type");

  BatchItem[] items;
  try
    items = parseMultipartBatch(body, boundary);
  catch (ODataException e)
    return errorResult(e.status, e.code, e.msg);

  auto responseBoundary = "batchresponse_" ~ randomUUID.toString;
  auto output = appender!string;

  foreach (item; items) {
    output ~= "--" ~ responseBoundary ~ "\r\n";
    if (!item.isChangeset) {
      string[string] noRefs;
      writeHttpPart(output, item.operation.contentId, execute(service, item.operation, noRefs));
      continue;
    }

    auto results = executeChangeset(service, item.changeset);
    if (results.length == 1 && results[0].isError && item.changeset.length != 1) {
      // failed changeset -> one error response for the whole changeset
      writeHttpPart(output, "", results[0]);
      continue;
    }
    auto changesetBoundary = "changesetresponse_" ~ randomUUID.toString;
    output ~= "Content-Type: multipart/mixed; boundary=" ~ changesetBoundary ~ "\r\n\r\n";
    foreach (i, result; results) {
      output ~= "--" ~ changesetBoundary ~ "\r\n";
      writeHttpPart(output, item.changeset[i].contentId, result);
    }
    output ~= "--" ~ changesetBoundary ~ "--\r\n";
  }
  output ~= "--" ~ responseBoundary ~ "--\r\n";

  ODataResult result;
  result.contentType = "multipart/mixed; boundary=" ~ responseBoundary;
  result.text = output.data;
  return result;
}

/// Processes a JSON $batch request (`{"requests":[{id, method, url, headers, body, atomicityGroup}]}`).
ODataResult processJsonBatch(ODataService service, Json body) {
  if (body.type != Json.Type.object || body["requests"].type != Json.Type.array)
    return errorResult(400, "BadRequest", "JSON batch must contain a 'requests' array");

  // group consecutive requests with the same atomicityGroup
  BatchOperation[][] groups;
  string[] groupNames;
  foreach (request; body["requests"].get!(Json[])) {
    BatchOperation op;
    op.contentId = request["id"].opt!string;
    op.method = request["method"].opt!string("GET");
    op.url = request["url"].opt!string;
    if (request["headers"].type == Json.Type.object)
      foreach (string name, value; request["headers"].byKeyValue)
        op.headers[name.toLower] = value.opt!string;
    op.body = request["body"];
    auto group = request["atomicityGroup"].opt!string;
    if (group.length && groupNames.length && groupNames[$ - 1] == group)
      groups[$ - 1] ~= op;
    else {
      groups ~= [op];
      groupNames ~= group;
    }
  }

  Json[] responses;
  foreach (g, group; groups) {
    ODataResult[] results;
    if (groupNames[g].length) {
      results = executeChangeset(service, group);
      if (results.length == 1 && group.length != 1) {
        // failed group: every request of the group fails
        foreach (op; group)
          responses ~= jsonResponse(op.contentId, results[0]);
        continue;
      }
    } else {
      string[string] noRefs;
      results = [execute(service, group[0], noRefs)];
    }
    foreach (i, result; results)
      responses ~= jsonResponse(group[i].contentId, result);
  }
  return jsonResult(200, Json(["responses": Json(responses)]));
}

// ---------------------------------------------------------------------------------------------
// execution
// ---------------------------------------------------------------------------------------------

private class ChangesetFailed : Exception {
  ODataResult result;

  this(ODataResult result) {
    this.result = result;
    super("changeset failed");
  }
}

/// Executes a changeset atomically. Returns one result per operation, or a single error result.
ODataResult[] executeChangeset(ODataService service, BatchOperation[] operations) {
  ODataResult[] results;
  string[string] references; // Content-ID -> resource path of created entity
  try {
    service.catalog.transaction(() @safe {
      foreach (op; operations) {
        auto result = execute(service, op, references);
        if (result.isError)
          throw new ChangesetFailed(result);
        if (op.contentId.length)
          if (auto location = "Location" in result.headers)
            references[op.contentId] = relativeTo(*location, service.serviceRoot);
        results ~= result;
      }
    });
  } catch (ChangesetFailed failure) {
    return [failure.result];
  }
  return results;
}

/// Executes a single operation, resolving "$<content-id>" references.
ODataResult execute(ODataService service, BatchOperation op, string[string] references) {
  auto url = op.url;
  if (url.startsWith("$")) {
    auto end = url.indexOf('/');
    auto id = url[1 .. end < 0 ? $ : end];
    if (auto target = id in references)
      url = *target ~ (end < 0 ? "" : url[end .. $]);
  }

  ODataRequest request;
  request.method = op.method;
  request.headers = op.headers;
  request.body = op.body;
  try
    splitServiceUrl(url, service.serviceRoot, request.path, request.query);
  catch (ODataException e)
    return errorResult(e.status, e.code, e.msg);
  if (request.path == "$batch")
    return errorResult(400, "BadRequest", "Nested $batch requests are not allowed");
  return service.handle(request);
}

private string relativeTo(string location, string serviceRoot) pure {
  return location.startsWith(serviceRoot) ? location[serviceRoot.length .. $] : location;
}

// ---------------------------------------------------------------------------------------------
// multipart parsing / writing
// ---------------------------------------------------------------------------------------------

/// Extracts the boundary parameter of a multipart Content-Type.
string boundaryOf(string contentType) pure {
  foreach (param; contentType.split(";")) {
    auto p = param.strip;
    if (p.toLower.startsWith("boundary=")) {
      auto value = p["boundary=".length .. $].strip;
      if (value.length >= 2 && value[0] == '"' && value[$ - 1] == '"')
        value = value[1 .. $ - 1];
      return value;
    }
  }
  return "";
}

BatchItem[] parseMultipartBatch(string body, string boundary) {
  BatchItem[] items;
  foreach (part; splitMultipart(body, boundary)) {
    string[string] headers;
    string content;
    splitHeaders(part, headers, content);
    auto contentType = headers.get("content-type", "");

    if (contentType.toLower.startsWith("multipart/mixed")) {
      BatchItem item;
      item.isChangeset = true;
      foreach (inner; splitMultipart(content, boundaryOf(contentType))) {
        string[string] innerHeaders;
        string innerContent;
        splitHeaders(inner, innerHeaders, innerContent);
        item.changeset ~= parseHttpOperation(innerContent, innerHeaders.get("content-id", ""));
      }
      items ~= item;
    } else {
      BatchItem item;
      item.operation = parseHttpOperation(content, headers.get("content-id", ""));
      items ~= item;
    }
  }
  return items;
}

/// Splits a multipart body into its parts (line endings normalized to "\n").
private string[] splitMultipart(string body, string boundary) {
  if (boundary.length == 0)
    throw badRequest("Missing multipart boundary");
  auto text = body.replace("\r\n", "\n");
  auto delimiter = "--" ~ boundary;
  string[] parts;
  bool started;
  string current;
  bool closed;
  foreach (line; text.lineSplitter) {
    auto trimmed = line.strip;
    if (trimmed == delimiter || trimmed == delimiter ~ "--") {
      if (started)
        parts ~= current;
      current = "";
      started = true;
      if (trimmed == delimiter ~ "--") {
        closed = true;
        break;
      }
      continue;
    }
    if (started)
      current ~= line ~ "\n";
  }
  if (!started)
    throw badRequest("Multipart boundary '" ~ boundary ~ "' not found in batch body");
  if (!closed)
    parts ~= current;
  return parts;
}

/// Splits "Header: value\n...\n\ncontent" (header names lower-cased).
private void splitHeaders(string part, out string[string] headers, out string content) {
  auto text = part;
  while (text.startsWith("\n"))
    text = text[1 .. $];
  auto blank = text.indexOf("\n\n");
  auto headerBlock = blank < 0 ? text : text[0 .. blank];
  content = blank < 0 ? "" : text[blank + 2 .. $];
  foreach (line; headerBlock.lineSplitter) {
    auto colon = line.indexOf(':');
    if (colon > 0)
      headers[line[0 .. colon].strip.toLower] = line[colon + 1 .. $].strip;
  }
}

/// Parses an embedded HTTP request ("GET Url HTTP/1.1\nHeaders\n\nBody").
private BatchOperation parseHttpOperation(string content, string contentId) {
  string[string] headers;
  string rest;
  auto text = content;
  while (text.startsWith("\n"))
    text = text[1 .. $];
  auto newline = text.indexOf('\n');
  auto requestLine = (newline < 0 ? text : text[0 .. newline]).strip;
  splitHeaders(newline < 0 ? "" : text[newline + 1 .. $], headers, rest);

  auto words = requestLine.split(" ");
  if (words.length < 2)
    throw badRequest("Invalid request line in batch part: '" ~ requestLine ~ "'");

  BatchOperation op;
  op.method = words[0];
  op.url = words[1];
  op.headers = headers;
  op.contentId = contentId.length ? contentId : headers.get("content-id", "");
  auto payload = rest.strip;
  if (payload.length)
    op.body = parseJsonString(payload);
  return op;
}

private void writeHttpPart(W)(ref W output, string contentId, ODataResult result) @trusted {
  output ~= "Content-Type: application/http\r\n";
  output ~= "Content-Transfer-Encoding: binary\r\n";
  if (contentId.length)
    output ~= "Content-ID: " ~ contentId ~ "\r\n";
  output ~= "\r\n";
  output ~= "HTTP/1.1 " ~ result.status.to!string ~ " " ~ httpStatusText(result.status) ~ "\r\n";
  auto payload = result.payload;
  if (result.contentType.length && result.status != 204)
    output ~= "Content-Type: " ~ result.contentType ~ "\r\n";
  output ~= "OData-Version: 4.0\r\n";
  foreach (name, value; result.headers)
    output ~= name ~ ": " ~ value ~ "\r\n";
  output ~= "\r\n";
  if (result.status != 204 && payload.length)
    output ~= payload ~ "\r\n";
}

private Json jsonResponse(string id, ODataResult result) {
  auto response = Json.emptyObject;
  response["id"] = id;
  response["status"] = result.status;
  auto headers = Json.emptyObject;
  if (result.contentType.length)
    headers["content-type"] = result.contentType;
  foreach (name, value; result.headers)
    headers[name.toLower] = value;
  response["headers"] = headers;
  if (result.hasJson)
    response["body"] = result.json;
  else if (result.text.length)
    response["body"] = result.text;
  return response;
}

///
unittest {
  assert(boundaryOf("multipart/mixed; boundary=batch_123") == "batch_123");
  assert(boundaryOf(`multipart/mixed;boundary="abc"`) == "abc");

  enum body = "--batch_1\r\nContent-Type: application/http\r\nContent-Transfer-Encoding: binary\r\n\r\n"
    ~ "GET BaseBlocks?$select=ID,Name&$top=10 HTTP/1.1\r\nAccept: application/json\r\n\r\n\r\n"
    ~ "--batch_1\r\nContent-Type: multipart/mixed; boundary=changeset_a\r\n\r\n"
    ~ "--changeset_a\r\nContent-Type: application/http\r\nContent-Transfer-Encoding: binary\r\nContent-ID: 1\r\n\r\n"
    ~ "POST BaseBlocks HTTP/1.1\r\nContent-Type: application/json\r\n\r\n{\"Name\": \"New\"}\r\n"
    ~ "--changeset_a\r\nContent-Type: application/http\r\nContent-Transfer-Encoding: binary\r\nContent-ID: 2\r\n\r\n"
    ~ "DELETE BaseBlocks('BB-02') HTTP/1.1\r\n\r\n\r\n"
    ~ "--changeset_a--\r\n--batch_1--\r\n";

  auto items = parseMultipartBatch(body, "batch_1");
  assert(items.length == 2);
  assert(!items[0].isChangeset && items[0].operation.method == "GET" && items[0].operation.url.startsWith("BaseBlocks?"));
  assert(items[1].isChangeset && items[1].changeset.length == 2);
  assert(items[1].changeset[0].contentId == "1" && items[1].changeset[0].body["Name"].get!string == "New");
  assert(items[1].changeset[1].method == "DELETE" && items[1].changeset[1].body.type == Json.Type.undefined);
}
