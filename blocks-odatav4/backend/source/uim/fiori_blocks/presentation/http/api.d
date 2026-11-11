/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.http.api;

/// Plain JSON endpoints used by the Fiori shell (login, notifications, log history, health).
import std.algorithm : canFind, filter, min;
import std.array : array;
import std.conv : to, ConvException;
import std.string : toLower;

import vibe.data.json : Json, JSONException;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.status : HTTPStatus;

import uim.fiori_blocks.composition : AppContext;
import uim.fiori_blocks.ports.services;

@safe:

void registerApiRoutes(URLRouter router, AppContext context) {
  auto api = new ShellApi(context);
  router.post("/api/auth/login", &api.postLogin);
  router.get("/api/notifications", &api.getNotifications);
  router.get("/api/logs", &api.getLogs);
  router.get("/health", &api.getHealth);
}

class ShellApi {
  private AppContext _context;

  this(AppContext context) {
    _context = context;
  }

  /// POST /api/auth/login {"username": "...", "password": "..."}
  void postLogin(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    string username, password;
    try {
      auto payload = req.json;
      username = payload["username"].opt!string;
      password = payload["password"].opt!string;
    } catch (JSONException) {
      res.writeJsonBody(Json(["authenticated": Json(false), "message": Json("Ungueltiger Request-Body.")]),
        HTTPStatus.badRequest);
      return;
    }

    auto result = _context.authenticator.authenticate(username, password);
    if (!result.authenticated) {
      res.writeJsonBody(Json(["authenticated": Json(false), "message": Json(result.message)]), HTTPStatus.unauthorized);
      return;
    }
    res.writeJsonBody(Json([
      "authenticated": Json(true),
      "username": Json(result.username),
      "role": Json(result.role)
    ]));
  }

  /// GET /api/notifications - shell notifications (demo content + live entity counts).
  void getNotifications(HTTPServerRequest req, HTTPServerResponse res) {
    Json[] items = [
      notification("Import abgeschlossen", "42 Datensaetze wurden erfolgreich importiert.", "vor 2 Minuten", "Success"),
      notification("Qualitaetspruefung", "6 Datensaetze enthalten fehlende Pflichtfelder.", "vor 10 Minuten", "Warning"),
      notification("Synchronisation", "Naechste automatische Synchronisation um 16:30 Uhr.", "soeben", "Information")
    ];
    string summary;
    foreach (service; _context.catalog.all)
      summary ~= (summary.length ? ", " : "") ~ service.count.to!string ~ " " ~ service.name;
    items ~= notification("Datenbestand", summary, "aktuell", "Information");
    res.writeJsonBody(Json(["items": Json(items)]));
  }

  /// GET /api/logs?severity=&q=&from=&to=&limit=&offset=
  void getLogs(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto severity = req.query.get("severity", "");
    auto query = req.query.get("q", "").toLower;
    auto fromDate = req.query.get("from", "");
    auto toDate = req.query.get("to", "");
    auto limit = sizeParam(req.query.get("limit", ""), 20);
    auto offset = sizeParam(req.query.get("offset", ""), 0);

    auto filtered = demoLogs
      .filter!(e => severity.length == 0 || e.level == severity)
      .filter!(e => query.length == 0 || (e.message ~ " " ~ e.source ~ " " ~ e.user).toLower.canFind(query))
      .filter!(e => (fromDate.length == 0 || e.isoDate[0 .. 10] >= fromDate) && (toDate.length == 0 || e.isoDate[0 .. 10] <= toDate))
      .array;

    auto total = filtered.length;
    auto start = min(offset, total);
    auto end = min(start + limit, total);
    Json[] items;
    foreach (e; filtered[start .. end])
      items ~= Json([
        "level": Json(e.level), "message": Json(e.message), "timestamp": Json(e.timestamp),
        "isoDate": Json(e.isoDate), "source": Json(e.source), "user": Json(e.user)
      ]);

    res.writeJsonBody(Json([
      "items": Json(items), "total": Json(total), "limit": Json(limit), "offset": Json(start)
    ]));
  }

  /// GET /health - liveness probe for Cloud Foundry / monitoring.
  void getHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto sets = Json.emptyObject;
    foreach (service; _context.catalog.all)
      sets[service.name] = service.count;
    res.writeJsonBody(Json([
      "status": Json("UP"),
      "storage": Json(_context.storage.describe),
      "entitySets": sets
    ]));
  }
}

private Json notification(string title, string description, string timestamp, string state) {
  return Json([
    "title": Json(title), "description": Json(description), "timestamp": Json(timestamp), "state": Json(state)
  ]);
}

private size_t sizeParam(string raw, size_t fallback) {
  if (raw.length == 0)
    return fallback;
  try
    return raw.to!size_t;
  catch (ConvException)
    return fallback;
}

private struct LogEntry {
  string level, message, timestamp, isoDate, source, user;
}

private immutable LogEntry[] demoLogs = [
  LogEntry("Success", "Export abgeschlossen", "2026-09-29 10:12", "2026-09-29T10:12:00", "BlockExport", "admin"),
  LogEntry("Warning", "Pflichtfeld fehlt in 6 Datensaetzen", "2026-09-29 09:58", "2026-09-29T09:58:00", "QualityCheck", "admin"),
  LogEntry("Error", "Synchronisation fehlgeschlagen", "2026-09-29 09:40", "2026-09-29T09:40:00", "SyncJob", "viewer"),
  LogEntry("Success", "Anmeldung erfolgreich", "2026-09-29 09:32", "2026-09-29T09:32:00", "Auth", "viewer")
];
