/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation;

/// Presentation layer (driving adapters):
/// - odata: OData v4 service ($metadata, CRUD, query options, $batch) for SAP Fiori / UI5
/// - http:  vibe.d HTTP server, auth/notifications/logs/health endpoints, static frontend
/// - cli:   command line interface (server start, CRUD, import/export, metadata)
/// - gui:   GtkD desktop client (only in the `desktop` dub configuration, version `WithGui`)
public:
  import uim.fiori_blocks.presentation.odata;
  import uim.fiori_blocks.presentation.http;
  import uim.fiori_blocks.presentation.cli;
  import uim.fiori_blocks.presentation.gui;
