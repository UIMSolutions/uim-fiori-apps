/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.routes;

/// vibe.d binding of the OData service: one catch-all route under the service root.
import std.algorithm : canFind;
import std.conv : to;
import std.string : strip, toLower;

import vibe.data.json : Json, parseJsonString, JSONException;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

import uim.fiori_blocks.infrastructure.logging;
import uim.fiori_blocks.presentation.odata.batch;
import uim.fiori_blocks.presentation.odata.errors;
import uim.fiori_blocks.presentation.odata.service;
import uim.fiori_blocks.presentation.odata.url;

@safe:

/// Registers `<root>` and `<root>/*` for all methods.
void registerODataRoutes(URLRouter router, ODataService service) {
  auto root = service.serviceRoot; // ends with '/'
  void handler(HTTPServerRequest req, HTTPServerResponse res) @safe {
    handleODataRequest(service, req, res);
  }

  router.any(root[0 .. $ - 1], &handler);
  router.any(root ~ "*", &handler);
}

void handleODataRequest(ODataService service, HTTPServerRequest req, HTTPServerResponse res) @trusted {
  ODataResult result;
  try {
    auto url = req.requestURI;
    ODataRequest request;
    request.method = req.method.to!string;
    splitServiceUrl(url, service.serviceRoot, request.path, request.query);
    foreach (name, value; req.headers.byKeyValue)
      request.headers[name.toLower] = value;

    // MERGE / X-HTTP-Method tunneling used by some clients
    if (auto tunneled = "x-http-method" in request.headers)
      request.method = *tunneled;

    auto contentType = req.headers.get("Content-Type", "");
    auto body = hasBody(request.method) ? req.bodyReader.readAllUTF8() : "";

    if (request.path == "$batch") {
      if (request.method != "POST")
        result = errorResult(405, "MethodNotAllowed", "$batch requires POST");
      else if (contentType.toLower.canFind("multipart/mixed"))
        result = processMultipartBatch(service, contentType, body);
      else if (contentType.toLower.canFind("application/json"))
        result = processJsonBatch(service, parseJsonString(body));
      else
        result = errorResult(415, "UnsupportedMediaType", "$batch requires multipart/mixed or application/json");
    } else {
      if (body.strip.length)
        request.body = parseJsonString(body);
      result = service.handle(request);
    }
  } catch (ODataException e) {
    result = errorResult(e.status, e.code, e.msg);
  } catch (JSONException e) {
    result = errorResult(400, "InvalidJson", e.msg);
  }

  logDebug("OData %s %s -> %s", req.method, req.requestURI, result.status);
  writeResult(res, result);
}

private bool hasBody(string method) pure {
  return ["POST", "PUT", "PATCH", "MERGE"].canFind(method);
}

private void writeResult(HTTPServerResponse res, ODataResult result) {
  res.headers["OData-Version"] = "4.0";
  foreach (name, value; result.headers)
    res.headers[name] = value;
  res.statusCode = result.status;
  if (result.status == 204 || (result.payload.length == 0 && !result.hasJson)) {
    res.writeVoidBody();
    return;
  }
  res.writeBody(result.payload, result.contentType);
}
