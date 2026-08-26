module uim.fiori.projectmanager.presentation.ui5.projects;

import uim.fiori.projectmanager;

@safe:

class ProjectUI5Controller {
    private ProjectUseCase usecase;

    this(ProjectUseCase usecase) {
        this.usecase = usecase;
    }

    void addRoutes(URLRouter router) {
        router.get("/odata/v4/$metadata", &getMetadata);
        router.get("/odata/v4/", &getServiceDocument);

        // EntitySets (Projekte & Todos)
        router.get("/odata/v4/Projects", &getProjects);
        router.get("/odata/v4/Projects(:id)", &getProject);
        router.post("/odata/v4/Projects", &createProject);
        router.patch("/odata/v4/Projects(:id)", &updateProject);
        router.delete_("/odata/v4/Projects(:id)",  & deleteProject);

        router.get("/odata/v4/Todos", &readTodos);
        router.post("/odata/v4/Todos", &createTodo);
        router.get("/odata/v4/Todos(:id)", &readTodo);
        router.patch("/odata/v4/Todos(:id)", &updateTodo);
        router.delete_("/odata/v4/Todos(:id)",  &deleteTodo);

        // Navigation Property / Context Binds: /Projects(1)/Todos
        router.get("/odata/v4/Projects(:id)/Todos", &getProjectTodos);
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Listing projects...");

        auto projects = usecase.listProjects();
        res.writeJsonBody(projects);
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching project...");

        int id = req.params["id"].to!int;
        auto project = usecase.getProject(id);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
        }
        res.writeJsonBody(project);
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Creating project...");

        auto json = req.json;
        Project newProj = Project();
        newProj.name = json.getString("name");
        newProj.description = json.getString("description");
        newProj.todos = null;

        usecase.createProject(newProj.name, newProj.description, newProj.todos);
        res.writeJsonBody(newProj);
    }

    void updateProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Updating project...");

        int id = req.params["id"].to!int;
        auto json = req.json;

        auto project = usecase.getProject(id);
        if (project != Project.init) {
            project.name = json.getString("name");
            project.description = json.getString("description");
            usecase.updateProject(id, project.name, project.description, project.todos);
            res.writeJsonBody(project);
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
        }
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Deleting project...");

        int id = req.params["id"].to!int;
        bool found = false;
        found = usecase.deleteProject(id);

        if (found) {
            res.statusCode = HTTPStatus.ok;
            res.writeJsonBody(["status": "success"]);
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
        }
    }

    // --- Todo-Endpoints ---
    void createTodo(HTTPServerRequest req, HTTPServerResponse res) {
        int projId = req.params["id"].to!int;
        auto json = req.json;

        auto project = usecase.getProject(projId);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return;
        }

        Todo newTodo;
        newTodo.id = nextTodoId++;
        newTodo.title = json["title"].get!string;
        newTodo.completed = false;

        project.todos ~= newTodo;
        usecase.updateProject(projId, project.name, project.description, project.todos);
        res.writeJsonBody(newTodo);
    }

    void deleteTodo(HTTPServerRequest req, HTTPServerResponse res) {
        import std.algorithm : remove;

        int projId = req.params["projectId"].to!int;
        int todoId = req.params["todoId"].to!int;

        auto project = usecase.getProject(projId);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Not found"]);
            return;
        }

        project.todos = project.todos.remove!(t => t.id == todoId);
        res.statusCode = HTTPStatus.ok;
        res.writeJsonBody(["status": "success"]);
    }
}
