/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.http.server;

/// vibe.d HTTP server: CORS, JSON API, OData v4 service and the static Fiori frontend.
import std.file : exists;

import vibe.core.core : runApplication;
import vibe.http.fileserver : serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;
import vibe.http.common : HTTPMethod;

import uim.fiori_blocks.composition : AppContext;
import uim.fiori_blocks.infrastructure.logging;
import uim.fiori_blocks.presentation.http.api;
import uim.fiori_blocks.presentation.odata;

@safe:

URLRouter buildRouter(AppContext context) {
  auto config = context.config;
  auto router = new URLRouter;

  if (config.cors)
    router.any("*", &handleCors);

  registerApiRoutes(router, context);

  auto odata = new ODataService(context.catalog, config.odataPath ~ "/", config.odataNamespace, config.odataContainer);
  registerODataRoutes(router, odata);

  if (config.publicDir.exists)
    router.get("*", serveStaticFiles(config.publicDir));
  else
    logWarn("Frontend directory '%s' not found - serving API only", config.publicDir);
  return router;
}

/// Starts the HTTP server and blocks until the event loop ends (Ctrl+C).
int runServer(AppContext context) {
  auto config = context.config;
  auto settings = new HTTPServerSettings;
  settings.port = config.port;
  settings.bindAddresses = config.bindAddresses;

  auto router = buildRouter(context);
  foreach (route; router.getAllRoutes)
    logDiagnostic("%-7s %s", route.method, route.pattern);

  auto listener = listenHTTP(settings, router);
  scope (exit)
    listener.stopListening();

  logInfo("Blocks OData v4 service: http://%s:%s%s/  (storage: %s, config: %s)",
    config.bindAddresses[0], config.port, config.odataPath, context.storage.describe, config.sources);
  return runApplication();
}

/// Development CORS (UI5 tooling on another port). Disabled with BLOCKS_CORS=false behind the approuter.
void handleCors(HTTPServerRequest req, HTTPServerResponse res) {
  res.headers["Access-Control-Allow-Origin"] = req.headers.get("Origin", "*");
  res.headers["Access-Control-Allow-Methods"] = "GET, HEAD, POST, PUT, PATCH, MERGE, DELETE, OPTIONS";
  res.headers["Access-Control-Allow-Headers"] =
    "Content-Type, Accept, Authorization, OData-Version, OData-MaxVersion, X-CSRF-Token, Prefer, If-Match";
  res.headers["Access-Control-Expose-Headers"] = "OData-Version, Location, X-CSRF-Token";
  if (req.method == HTTPMethod.OPTIONS)
    res.writeVoidBody();
}
