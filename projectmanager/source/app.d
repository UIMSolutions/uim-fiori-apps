module projectmanager.app;

import vibe.d;
import domain;
import application;
import adapters.memory_repo;
import adapters.web;

void main() {
    auto repository = new InMemoryProjectRepository();
    auto service = new ProjectService(repository);
    auto controller = new ProjectHttpController(service);

    // Seed data for local development.
    service.createProject("Website Redesign", "Relaunch der Firmenwebsite", [
        Todo(101, "Wireframes erstellen", true),
        Todo(102, "vibe.d REST API bauen", false)
    ]);
    service.createProject("Fiori App", "Entwicklung der Master-Detail App", [
        Todo(201, "SAPUI5 Views anlegen", false)
    ]);

    auto router = new URLRouter;

    // REST API Routes
    router.get("/api/projects", &controller.listProjects);
    router.get("/api/projects/*", &controller.getProject);
    router.post("/api/projects", &controller.createProject);
    router.put("/api/projects/*", &controller.updateProject);
    router.delete_("/api/projects/*", &controller.deleteProject);

    // Route for homepage and static SAPUI5 frontend files.
    router.get("/", serveStaticFile("public/index.html"));
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);
    runApplication();
}