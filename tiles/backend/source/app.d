module app;
import vibe.d;
import std.conv : to;
import domain;
import controller;
import uim.fiori;
import std.process : environment;
@safe:
void main() {
    auto settings = new HTTPServerSettings;
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];
    auto router = new URLRouter;
    router.get("/odata/v4/TileService/$metadata", &getMetadata);
    router.get("/odata/v4/TileService", &getServiceDocument);
    router.get("/odata/v4/TileService/", &getServiceDocument);
    router.get("/odata/v4/TileService/Tiles*", &getTiles);
    // Serve SAPUI5 frontend for standalone local runs.
    router.get("*", serveStaticFiles("../frontend/webapp/"));
    listenHTTP(settings, router);
    runApplication();
}
