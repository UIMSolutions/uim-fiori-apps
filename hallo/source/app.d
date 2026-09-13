module app;
import vibe.d;
import std.process : environment;
import std.conv : to;
void getHello(HTTPServerRequest req, HTTPServerResponse res)
{
    Json payload = Json.emptyObject;
    payload["message"] = "Hallo Welt aus dem vibe.d Backend!";
    payload["timestamp"] = Clock.currTime().toISOString();
    
    res.writeJsonBody(payload);
}
void main()
{
    auto settings = new HTTPServerSettings;
    
    // Cloud Foundry Port aus Umgebungsvariable auslesen
    ushort port = to!ushort(environment.get("PORT", "8080"));
    settings.port = port;
    settings.bindAddresses = ["0.0.0.0"];
    auto router = new URLRouter;
    
    // API Endpoint für Fiori
    router.get("/api/hello", &getHello);
    
    // Statische SAPUI5/Fiori Dateien aus /public servieren
    router.get("*", serveStaticFiles("public/"));
    listenHTTP(settings, router);
    logInfo("Server läuft auf Port %d...", port);
    
    runApplication();
}