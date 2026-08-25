module app;

import vibe.d;
import domain;
import adapters.memory_repo;
import adapters.web;
import adapters.odata_dto;
import std.process : environment;
import uim.framework;
import helpers;

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
    writeln("Handling CORS for request: ", req.method, " ", req.requestURL);

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

void checkAuth(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("Checking Authorization for request: ", req.method, " ", req.requestURL);

    auto authHeader = req.headers.get("Authorization", "");
    
    if (!authHeader.startsWith("Bearer ")) {
        res.statusCode = HTTPStatus.unauthorized;
        writeODataJson(res, ["error": "Missing or invalid Authorization header"], HTTPStatus.unauthorized);
        return;
    }
    
    string token = authHeader[7 .. $];
    // Optional: JWT-Token verifizieren (z. B. via Public Key von XSUAA)
    // res.headers["X-CSRF-Token"] = "Fetch"; // Beispiel: CSRF-Token setzen
    // res.headers["OData-Version"] = "4.0"; // OData-Version setzen
    // res.writeBody(""); // Weiterleitung an den nächsten Handler 
}

void main() {
    auto repo = new InMemoryTaskRepository();
    auto service = new TaskService(repo);
    auto controller = new ODataTaskController(service);

    auto router = new URLRouter;

    router.any("*", &handleCORS);
    // Middleware in vibe.d einbinden:
    // router.any("/odata/*", &checkAuth);

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
    
    ushort port = environment.get("PORT", "8080").to!ushort;
    settings.port = environment.get("PORT", "8080").to!ushort;
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);
    runApplication();

}
