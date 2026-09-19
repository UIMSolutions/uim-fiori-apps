module app;

import uim.fiori;
import uim.fiori.landscape;

void main() {
    auto repository = new InMemoryLandscapeRepository();
    auto service = new LandscapeService(repository);
    auto controller = new LandscapeODataController(service);
    auto router = new URLRouter();
    router.any("*", &enableCORS);
    controller.registerRoutes(router);

    auto appView = new App2View("/view/App.view.xml");
    appView.registerRoutes(router);
    router.get("/resources/*", serveStaticFiles("/home/oz/DEV/D/UIM2026/SAP/uim-fiori-apps/public/sapui5-sdk-1.151.0/"));
    router.get("/", &showIndex);
    // router.get("/", serveStaticFiles("public/index.html"));
    router.get("*", serveStaticFiles("public/"));
    
    auto settings = new HTTPServerSettings();
    settings.bindAddresses = ["0.0.0.0"];
    settings.port = 8081;
    listenHTTP(settings, router);
    logInfo("Landscape OData service listening on http://localhost:8081/odata/v4/landscape-service/");
    runApplication();
}

void showIndex(HTTPServerRequest req, HTTPServerResponse res) {
    // Renders views/index.dt automatically
    res.render!"index.dt";
}
    