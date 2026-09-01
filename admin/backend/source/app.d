module app;

import vibe.d;
import std.conv : to;
import std.process : environment;
import uim.fiori.admin;;

@safe:

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];

    auto router = new URLRouter;

    auto adminService = new AdminService();
    adminService.registerRoutes(router);

    // Local fallback: static UI5 web assets when backend runs standalone.
    router.get("/", serveStaticFiles("../frontend/webapp/index.html"));
    router.get("*", serveStaticFiles("../frontend/webapp/"));

    listenHTTP(settings, router);

    logInfo("Admin backend listening on port %s", settings.port);
    runApplication();
}
