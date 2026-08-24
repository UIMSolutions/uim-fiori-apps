module app;

import vibe.d;
import domain;
import adapters.memory_repo;
import adapters.web;
import adapters.odata_dto;

@safe:
// REST API Interface für vibe.d RestInterfaceHTTP
@path("/api/tasks")
interface TaskAPI {
@safe:
    TodoTask[] get();
    TodoTask post(string title, string description);
    TodoTask put(string id, string title, string description, bool isCompleted);
    void delete_(string id);
}

class TaskAPIImpl : TaskAPI {
    private domain.TaskService service;

    this(domain.TaskService service) {
        this.service = service;
    }

    override TodoTask[] get() {
        return service.getAllTasks();
    }

    override TodoTask post(string title, string description) {
        return service.createTask(title, description);
    }

    override TodoTask put(string id, string title, string description, bool isCompleted) {
        return service.updateTask(id, title, description, isCompleted);
    }

    override void delete_(string id) {
        service.deleteTask(id);
    }
}

void handleCORS(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PATCH, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, X-CSRF-Token";
    
    // Wenn es ein OPTIONS Preflight-Request ist, sofort beenden
    if (req.method == HTTPMethod.OPTIONS) {
        res.statusCode = HTTPStatus.ok;
        res.writeBody("");
        return;
    }
}

void main() {
    auto repo = new InMemoryTaskRepository();
    auto service = new TaskService(repo);
    auto controller = new ODataTaskController(service);

    auto router = new URLRouter;

    router.any("*", &handleCORS);
    
    // Metadata & Collection
    router.get("/odata/v4/TaskService/$metadata", &controller.getMetadata);
    router.get("/odata/v4/TaskService/Tasks", &controller.getTasks);
    router.get("/odata/v4/TaskService/Tasks/", &controller.getTasks);
    router.post("/odata/v4/TaskService/Tasks", &controller.createTask);
    router.post("/odata/v4/TaskService/Tasks/", &controller.createTask);

    // Einzelentitäten: fange OData-Formate wie Tasks('id') oder Tasks(id) ab
    // Parameter :id greift hier den gesamten Schlüssel inklusive Klammern/Anführungszeichen ab
    router.get("/odata/v4/TaskService/Tasks:id", &controller.getTask);
    router.patch("/odata/v4/TaskService/Tasks:key", &controller.updateTask);
    router.delete_("/odata/v4/TaskService/Tasks:key", &controller.deleteTask);

    // Route für die Startseite explizit angeben
    router.get("/", serveStaticFile("public/index.html"));

    // Statische Dateien (js, xml, json, html) aus public/ bereitstellen
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"]; // für IPv6 + IPv4

    listenHTTP(settings, router);
    runApplication();

}
