module app;

import uim.fiori.materials;
import uim.fiori.views.app;

import std.process : environment;
void main() {
    auto repositories = createRepositoryBundle();
    auto service = new MaterialApplicationService(
        repositories.materials,
        repositories.planning,
        repositories.warehouses,
        repositories.stocks,
        repositories.suppliers
    );

    auto router = new URLRouter();
    router.any("*", &enableCORS);
    auto controller = new MaterialODataController(service);
    controller.registerRoutes(router);

    auto appView = new XAppView("/view/App.view.xml");
    appView.registerRoutes(router);
    // appView.render();
    // router.get("/", serveStaticFiles("public/index.html"));
    router.get("/", &showIndex);
    router.get("/resources/*", serveStaticFiles("/home/oz/DEV/D/UIM2026/SAP/uim-fiori-apps/public/sapui5-sdk-1.151.0/"));
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings();
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];

    writeln("Starting HTTP server...");
    listenHTTP(settings, router);
    logInfo("Material OData service listening on http://localhost:8080/odata/v4/material-service/");
    logInfo("Persistence adapter: %s", repositories.selectedAdapter);
    runApplication();
}

void showIndex(HTTPServerRequest req, HTTPServerResponse res) {
    // Renders views/index.dt automatically
    res.render!"index.dt";
}
