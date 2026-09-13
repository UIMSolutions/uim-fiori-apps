
module app;
import vibe.d;
import std.process : environment;
import std.conv : to;
import models;
import service;
@safe:
/// Middleware zur Behandlung von Cross-Origin Resource Sharing (CORS)
/// Dies erlaubt dem UI5 Dev-Server (z.B. Port 3000) Anfragen an das vibe.d Backend zu stellen.
void enableCORS(HTTPServerRequest req, HTTPServerResponse res) {
    // Erlaube Zugriffe von jedem Ursprung (für lokale Entwicklung)
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, X-Requested-With";
    // Preflight-Anfragen (OPTIONS) direkt mit 200 OK beantworten
    if (req.method == HTTPMethod.OPTIONS) {
        res.writeBody("", 200);
        return;
    }
}
void main() {
    auto router = new URLRouter;
    // 1. In-Memory Data Repository und Service-Instanz erzeugen
    auto repo = new ContactRepository();
    auto contactService = new ContactService(repo);
    // 2. CORS-Middleware global registrieren (vor den Routen)
    router.any("*", &enableCORS);
    // 3. REST-Interface für Kontakte unter /api/v1 registrieren
    // Generiert automatisch Routen wie GET/POST /api/v1/Contacts
    router.registerRestInterface(contactService);
    // 4. Status- und Health-Check Endpunkt (nützlich für Cloud Foundry Probes)
    router.get("/health", (HTTPServerRequest req, HTTPServerResponse res) {
        res.writeJsonBody(["status": "UP", "service": "Contact Manager Backend"]);
    });
    // 5. Server-Einstellungen konfigurieren
    auto settings = new HTTPServerSettings;
    // Liest den Port aus der Umgebungsvariable `PORT` (von Cloud Foundry gesetzt).
    // Wenn lokal keine Variable gesetzt ist, wird standardmäßig Port 8080 verwendet.
    ushort port = to!ushort(environment.get("PORT", "8080"));
    settings.port = port;
    // settings.bindAddresses = ["0.0.0.0"];
    // Bind auf "::" (IPv6 & IPv4 wildcard), erforderlich für Docker/Cloud Foundry Container
    settings.bindAddresses = ["::"];
    // HTTP-Listener starten
    listenHTTP(settings, router);
    logInfo("==================================================");
    logInfo("vibe.d Contact Manager Backend gestartet");
    logInfo("Server lauscht auf: http://localhost:%d", port);
    logInfo("REST API verfügbar unter: http://localhost:%d/api/v1/Contacts", port);
    logInfo("==================================================");
    runApplication();
}