module uim.fiori.projectmanager.presentation.http.projects;

import uim.fiori.projectmanager;

@safe:

class ProjectHttpController {
    private ProjectUseCase usecase;

    this(ProjectUseCase usecase) {
        this.usecase = usecase;
    }

    void addRoutes(URLRouter router) {
        router.get("/api/projects", &listProjects);
        router.get("/api/projects/:id", &getProject);
        router.post("/api/projects", &createProject);
        router.put("/api/projects/:id", &updateProject);
        router.delete_("/api/projects/:id", &deleteProject);

        router.post("/api/projects/:id/todos", &createTodo);
        router.delete_("/api/projects/:projectId/todos/:todoId", &deleteTodo);
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Listing projects...");

        auto projects = usecase.listProjects();

        writeln("Projects: ", projects);
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
        writeln("Project created: ", newProj);

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
        Project project = usecase.deleteProject(id);

        if (project != Project.init) {
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
