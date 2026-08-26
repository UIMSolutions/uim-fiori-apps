module app;

import uim.fiori.projectmanager;
import std.process : environment;

@safe:
version (unittest) {
} else {
    void main() {

        // Pfad für die persistenten Daten bestimmen:
        // In CF bietet sich /tmp an, da das Hauptverzeichnis oft read-only ist.
        string dataDir = environment.get("DATA_DIR", "/tmp");
        string dbFilePath = buildPath(dataDir, "projects.json");

        auto projectRepository = new FileProjectRepository(dbFilePath);
        auto todoRepository = new TodoRepository();
        auto projectUsecase = new ProjectUseCase(projectRepository, todoRepository);

        auto projectController = new ProjectHttpController(projectUsecase);
        // auto todoController = new TodoHttpController(todoRepository);

        auto projectUI5Controller = new ProjectUI5Controller(projectUsecase);

        auto router = new URLRouter;
        router.any("*", &handleCORS);
        router.any("/odata/v4/*", &setODataHeaders);

        // REST API Routes
        // API Routen
        projectController.addRoutes(router);
        projectUI5Controller.addRoutes(router);

        // Route for homepage and static SAPUI5 frontend files.
        router.get("/", serveStaticFile("webapp/index.html"));
        router.get("*", serveStaticFiles("webapp/"));
        router.get("*", serveStaticFiles("public/"));
        
        ushort port = environment.get("PORT", "8080").to!ushort;
        auto settings = new HTTPServerSettings;
        settings.port = port;
        settings.bindAddresses = ["0.0.0.0"]; // Auf allen Interfaces lauschen
        listenHTTP(settings, router);
        runApplication();
    }
}
