module app;
import uim.fiori.material;
import std.process : environment;
void main() {
    auto repositories = createRepositoryBundle();
    auto service = new MaterialApplicationService(
        repositories.materials,
        repositories.planning,
        repositories.warehouses,
        repositories.stocks
    );
    auto controller = new MaterialODataController(service);
    auto router = new URLRouter();
    router.any("*", &enableCORS);
    controller.registerRoutes(router);
    auto appView = new AppView("/view/App.view.xml");
    appView.addRoutes(router);
    appView.render();
    router.get("/", serveStaticFiles("../frontend/webapp/index.html"));
    router.get("*", serveStaticFiles("../frontend/webapp/"));
    auto settings = new HTTPServerSettings();
    settings.bindAddresses = ["0.0.0.0"];
    settings.port = to!ushort(environment.get("PORT", "8080"));
    listenHTTP(settings, router);
    logInfo("Material OData service listening on http://localhost:8080/odata/v4/material-service/");
    logInfo("Persistence adapter: %s", repositories.selectedAdapter);
    runApplication();
}

