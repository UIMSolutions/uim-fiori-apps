module app;

import uim.fiori.projectmanager;

@safe:

@safe:
version (unittest) {
} else {
    void main() {
        auto projectRepository = new ProjectRepository();
        auto todoRepository = new TodoRepository();
        auto projectUsecase = new ProjectUseCase(projectRepository, todoRepository);

        auto projectController = new ProjectHttpController(projectUsecase);
        // auto todoController = new TodoHttpController(todoRepository);

        auto projectUI5Controller = new ProjectUI5Controller(projectUsecase);

        // Seed data for local development.
        projectUsecase.createProject("Website Redesign", "Relaunch der Firmenwebsite", [
                Todo(101, "Wireframes erstellen", true),
                Todo(102, "vibe.d REST API bauen", false)
            ]);
        projectUsecase.createProject("Fiori App", "Entwicklung der Master-Detail App", [
                Todo(201, "SAPUI5 Views anlegen", false)
            ]);

        auto router = new URLRouter;
        router.any("*", &handleCORS);
        router.any("/odata/v4/*", &setODataHeaders);

        // REST API Routes
        // API Routen
        projectController.addRoutes(router);
        projectUI5Controller.addRoutes(router);

        // Route for homepage and static SAPUI5 frontend files.
        router.get("/", serveStaticFile("public/index.html"));
        router.get("*", serveStaticFiles("public/"));

        auto settings = new HTTPServerSettings;
        settings.port = 8080;
        settings.bindAddresses = ["0.0.0.0"];

        listenHTTP(settings, router);
        runApplication();
    }
}
