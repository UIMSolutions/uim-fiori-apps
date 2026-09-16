import vibe.d;
import std.process : environment;
import std.conv : to;
import std.algorithm : remove, countUntil;
import std.string : indexOf, CaseSensitive;
@safe:
// Datenmodell für Aufgaben
struct Task {
    string id;
    string title;
    string description;
    string priority; // High, Medium, Low
    string status;   // Open, InProgress, Completed
    string createdAt;
}
// REST Interface
@path("/api/v1")
interface ITaskService {
    @path("/tasks")
    Task[] getTasks(string search = null);
    @path("/tasks/:id")
    Task getTask(string _id);
    @path("/tasks")
    @method(HTTPMethod.POST)
    Task createTask(Task task);
    @path("/tasks/:id")
    @method(HTTPMethod.PUT)
    Task updateTask(string _id, Task task);
    @path("/tasks/:id")
    @method(HTTPMethod.DELETE)
    void deleteTask(string _id);
}
// Implementation
class TaskService : ITaskService {
    private Task[] m_tasks;
    this() {
        m_tasks = [
            Task("1", "XSUAA Token Validation", "JWT Signaturprüfung mit RS256 im Backend integrieren", "High", "InProgress", "2026-08-25"),
            Task("2", "HANA Cloud Binding", "mta.yaml um HDI-Container erweitern", "Medium", "Open", "2026-08-26"),
            Task("3", "UI5 FlexibleColumnLayout", "Master-Detail View für Aufgabendetails umsetzen", "High", "Completed", "2026-08-27")
        ];
    }
    override Task[] getTasks(string search = null) {
        if (search.length == 0) return m_tasks;
        Task[] filtered;
        foreach (t; m_tasks) {
            if (t.title.indexOf(search, CaseSensitive.no) >= 0) filtered ~= t;
        }
        return filtered;
    }
    override Task getTask(string _id) {
        foreach (t; m_tasks) {
            if (t.id == _id) return t;
        }
        throw new HTTPStatusException(HTTPStatus.notFound, "Task nicht gefunden");
    }
    override Task createTask(Task task) {
        task.id = to!string(m_tasks.length + 1);
        task.createdAt = Clock.currTime().toISOString()[0 .. 10];
        m_tasks ~= task;
        return task;
    }
    override Task updateTask(string _id, Task task) {
        foreach (i, ref t; m_tasks) {
            if (t.id == _id) {
                task.id = _id;
                t = task;
                return t;
            }
        }
        throw new HTTPStatusException(HTTPStatus.notFound, "Task nicht gefunden");
    }
    override void deleteTask(string _id) {
        auto idx = m_tasks.countUntil!(t => t.id == _id);
        if (idx >= 0) m_tasks = m_tasks.remove(idx);
    }
}
void main() {
    auto settings = new HTTPServerSettings;
    ushort port = to!ushort(environment.get("PORT", "8080"));
    settings.port = port;
    settings.bindAddresses = ["0.0.0.0"];
    auto router = new URLRouter;
    
    // REST API registrieren
    router.registerRestInterface(new TaskService());
    // Explicit Redirect/Serve für die Startseite
    router.get("/", serveStaticFiles("public/index.html"));
    
    // Statische Dateien bereitstellen
    router.get("*", serveStaticFiles("public/"));
    listenHTTP(settings, router);
    runApplication();
}