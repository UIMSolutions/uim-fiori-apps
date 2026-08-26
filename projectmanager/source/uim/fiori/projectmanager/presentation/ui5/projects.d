module uim.fiori.projectmanager.presentation.ui5.projects;

import std.conv : to;
import std.stdio : writeln;
import uim.fiori.projectmanager;
import vibe.data.json;
import vibe.http.server;
import vibe.http.router;

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
        router.get("/odata/v4/Projects*", &getProjects);
        router.post("/odata/v4/Projects*", &createProject);

        router.patch("/odata/v4/Projects*", &updateProject);
        router.delete_("/odata/v4/Projects*", &deleteProject);

        router.get("/odata/v4/Todos*", &listTodos);
        router.post("/odata/v4/Todos", &createTodo);
        router.patch("/odata/v4/Todos*", &updateTodo);
        router.delete_("/odata/v4/Todos*", &deleteTodo);

        // Navigation Property: /Projects(1)/Todos
        router.get("/odata/v4/Projects\\(:id\\)/Todos", &getProjectTodos);
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching OData metadata");

        res.contentType = "application/xml";
        string xml = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="ProjectService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Project">
        <Key><PropertyRef Name="Id" /></Key>
        <Property Name="Id" Type="Edm.Int32" Nullable="false" />
        <Property Name="Name" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <NavigationProperty Name="Todos" Type="Collection(ProjectService.Todo)" />
      </EntityType>
      <EntityType Name="Todo">
        <Key><PropertyRef Name="Id" /></Key>
        <Property Name="Id" Type="Edm.Int32" Nullable="false" />
        <Property Name="Title" Type="Edm.String" />
        <Property Name="Completed" Type="Edm.Boolean" Nullable="false" />
      </EntityType>
      <EntityContainer Name="EntityContainer">
        <EntitySet Name="Projects" EntityType="ProjectService.Project">
          <NavigationPropertyBinding Path="Todos" Target="Todos" />
        </EntitySet>
        <EntitySet Name="Todos" EntityType="ProjectService.Todo" />
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
        res.writeBody(xml);
    }

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching OData service document");

        res.writeODataJson(Json.emptyObject
                .set("@odata.context", "/odata/v4/$metadata")
                .set("value", [
                        [
                            "name": "Projects",
                            "kind": "EntitySet",
                            "url": "Projects"
                        ].toJson,
                        ["name": "Todos", "kind": "EntitySet", "url": "Todos"].toJson
                    ].toJson)
        );
    }

    void getProjects(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching all projects");
        writeln("Path info: ", req.requestPath.toString());

        if (req.requestPath.toString() == "/odata/v4/Projects") {
            writeln("Fetching all projects without specific ID");

            Json result = Json.emptyArray;
            foreach (p; usecase.listProjects()) {
                result ~= Json.emptyObject
                    .set("Id", p.id)
                    .set("Name", p.name)
                    .set("Description", p.description)
                    .set("Todos", p.todos.map!(t => Json.emptyObject
                            .set("Id", t.id)
                            .set("Title", t.title)
                            .set("Completed", Json(t.completed))).array.toJson);
            }

            writeln("Resulting JSON for all projects: ", result);
            res.writeODataJson(Json.emptyObject
                    .set("@odata.context", "/odata/v4/$metadata#Projects")
                    .set("value", result));
            return;
        }

        auto parts = req.requestPath.toString().split("/");
        writeln("Request path parts: ", parts);
        Project project;
        Todo todo;
        foreach (part; parts) {
            if (part.startsWith("Projects(")) {
                auto idStr = part[9 .. $ - 1]; // Extract ID from "Projects(ID)"
                int projectId = idStr.to!int;
                project = usecase.getProject(projectId);
                if (project == Project.init) {
                    res.statusCode = HTTPStatus.notFound;
                    res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
                    return;
                }
            }

            if (part.startsWith("Todos(")) {
                auto idStr = part[6 .. $ - 1]; // Extract ID from "Todos(ID)"
                int todoId = idStr.to!int;
                todo = usecase.getTodo(todoId);
                if (todo == Todo.init) {
                    res.statusCode = HTTPStatus.notFound;
                    res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
                    return;
                }
            }
        }

        if (todo != Todo.init) {
            Json responseJson = Json.emptyObject;
            responseJson["@odata.context"] = Json("/odata/v4/$metadata#Projects/$entity");
            responseJson["Id"] = Json(todo.id);
            responseJson["Title"] = Json(todo.title);
            responseJson["Completed"] = Json(todo.completed);
            res.writeODataJson(responseJson);
            return;
        }
        if (project != Project.init) {
            Json responseJson = Json.emptyObject;
            responseJson["@odata.context"] = Json("/odata/v4/$metadata#Projects/$entity");
            responseJson["Id"] = Json(project.id);
            responseJson["Name"] = Json(project.name);
            responseJson["Description"] = Json(project.description);
            responseJson["Todos"] = project.todos.map!(t => Json.emptyObject
                    .set("Id", t.id)
                    .set("Title", t.title)
                    .set("Completed", Json(t.completed))).array.toJson;

            res.writeODataJson(responseJson);
            return;
        }
        res.statusCode = HTTPStatus.notFound;
        res.writeODataJson(Json.emptyObject.set("error", "Project or Todo not found"));
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching project with ID: ", req.params["id"]);
        res
            .headers["OData-Version"] = "4.0";
        if ("id" !in req.params) {
            res.statusCode = HTTPStatus.badRequest;
            return;
        }

        // ID bereinigen (entfernt ' und '3' -> 3)
        string rawId = req.params["id"].replace("'", "").strip();
        int projectId = rawId.to!int;
        auto proj = usecase.getProject(
            projectId); // Context-Header nach OData v4 Spezifikation
        auto responseJson = Json.emptyObject;
        responseJson["@odata.context"] = Json(
            "/odata/v4/$metadata#Projects/$entity");
        responseJson["Id"] = Json(
            proj.id);
        responseJson["Name"] = Json(proj.name);
        responseJson["Description"] = Json(proj.description);

        // Prüfen, ob $expand=Todos angefordert wurde
        if (req.queryString.contains("$expand=Todos")) {
            Json[] todosJson;
            foreach (t; usecase.listTodos(projectId)) {
                todosJson ~= Json.emptyObject
                    .set("Id", t.id)
                    .set("Title", t.title)
                    .set("Completed", Json(t.completed));
            }
            responseJson["Todos"] = Json(todosJson);
        }

        res.writeODataJson(responseJson);
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Creating project with request body: ", req
                .json);

        if (!req.path.contains("(")) { // Create Project
            writeln("Creating new project with request body: ", req.json);

            auto json = req.json;
            Project newProj = Project();
            // KORREKTUR: PascalCase für OData oder Abfangen fehlender Keys
            newProj.name = json.getString("Name", json.getString("name", ""));
            newProj.description = json.getString("Description", json.getString(
                    "description", ""));
            newProj.todos = null;

            newProj = usecase.createProject(newProj.name, newProj.description, newProj
                    .todos);
            res.statusCode = HTTPStatus.created;
            res.writeODataJson(Json.emptyObject
                    .set("@odata.context", Json("/odata/v4/$metadata#Projects/$entity"))
                    .set("Id", Json(newProj.id))
                    .set("Name", Json(newProj.name))
                    .set("Description", Json(newProj.description)));
            return;
        }

        auto items = req.path.split("(");
        auto json = req.json;
        if (items.length == 2) {
            writeln("Creating todo for project with request body: ", json);

            writeln("Items after splitting by '(': ", items, " and last item: ", items[$ - 1]);
            auto strID = items[1].split(")")[0];
            int projectId = strID.to!int;
            auto project = usecase.getProject(projectId);
            if (project == Project.init) {
                res.statusCode = HTTPStatus.notFound;
                res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
                return;
            }

            items = req.path.split("/");
            writeln("Items after splitting by '/': ", items, " and last item: ", items[$ - 1]);
            if (items[$ - 1] == "Todos") {
                writeln("Creating new todo for project ID ", project.id, " with request body: ", json);
                writeln("Next Todo ID before increment: ", nextTodoId);

                Todo newTodo = usecase.createTodo(project.id, json.getString("Title", json.getString("title", "")), false);
                writeln("Created new todo for project ID ", project.id, ": ", newTodo, " data: ", project);

                res.statusCode = HTTPStatus.created;
                res.writeODataJson(Json.emptyObject
                        .set("@odata.context", Json("/odata/v4/$metadata#Todos/$entity"))
                        .set("Id", Json(newTodo.id))
                        .set("Title", Json(newTodo.title))
                        .set("Completed", Json(newTodo.completed)));
                return;
            }
        }
        res.statusCode = HTTPStatus.notFound;
        res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
        return;
    }

    void updateProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Updating project and request body: ", req.json);

        if (!req.path.contains("(")) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
            return;
        }

        auto parts = req.path.split("/");
        Project project;
        foreach (part; parts) {
            if (part.startsWith("Projects(")) {
                auto idStr = part[9 .. $ - 1]; // Extract ID from "Projects(ID)"
                int projectId = idStr.to!int;
                project = usecase.getProject(projectId);
                if (project == Project.init) {
                    res.statusCode = HTTPStatus.notFound;
                    res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
                    return;
                }
            }
        }

        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
        }

        auto json = req.json;
        writeln("Updating project with ID: ", project.id, " and request body: ", json);

        project.name = json.getString("Name", json.getString("name", project.name));
        project.description = json.getString("Description", json.getString("description", project
                .description));
        project = usecase.updateProject(project.id, project.name, project
                .description, project.todos);
        res.statusCode = HTTPStatus.ok;
        res.writeODataJson(project);
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Deleting project ..: ", req.requestPath.toString());
        // /Projects(3)/Todos(301)

        auto parts = req.requestPath.toString().split("/");
        writeln("Request path parts: ", parts);
        if (parts.length < 2) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
            return;
        }

        Project project;
        Todo todo;
        foreach (part; parts) {
            if (part.startsWith("Projects(")) {
                auto idStr = part[9 .. $ - 1]; // Extract ID from "Projects(ID)"
                int projectId = idStr.to!int;
                project = usecase.getProject(projectId);
            }

            if (part.startsWith("Todos(")) {
                auto idStr = part[6 .. $ - 1]; // Extract ID from "Todos(ID)"
                int todoId = idStr.to!int;
                bool found = usecase.deleteTodo(todoId);
                if (found) {
                    res.statusCode = HTTPStatus.noContent;
                    res.writeODataJson(Json(null));
                } else {
                    res.statusCode = HTTPStatus.notFound;
                    res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
                }
                return;
            }
        }

        if (todo == Todo.init && project != Project.init) {
            auto deletedProject = usecase.deleteProject(project.id);
            if (deletedProject != Project.init) {
                res.statusCode = HTTPStatus.noContent;
                res.writeODataJson(Json(null));
            } else {
                res.statusCode = HTTPStatus.notFound;
                res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
            }
        } else {
            res.statusCode = HTTPStatus.badRequest;
            res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
        }
    }

    // --- Todo-Endpoints ---
    void createTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Creating todo with request body: ", req.json);

        auto json = req.json; // KORREKTUR: ProjectId aus Request-Body lesen, da in Route kein :id
        int projId = json.getInteger("ProjectId", 0);

        auto project = usecase.getProject(projId);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeODataJson(Json.emptyObject.set("error", "Project not found"));
            return;
        }

        Todo newTodo;
        nextTodoId = nextTodoId + 1;
        newTodo.id = nextTodoId++;
        newTodo.title = json.getString("Title", json.getString("title", ""));
        newTodo.completed = false;

        project.todos ~= newTodo;
        usecase.updateProject(projId, project.name, project
                .description, project.todos);

        res.statusCode = HTTPStatus.created;
        res.writeODataJson(Json.emptyObject
                .set("@odata.context", Json("/odata/v4/$metadata#Todos/$entity"))
                .set("Id", Json(newTodo.id))
                .set("Title", Json(newTodo.title))
                .set("Completed", Json(
                    newTodo.completed)));
    }

    void deleteTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Deleting todo ...", req.requestPath.toString());

        if (!req.path.contains("(")) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
            return;
        }

        auto items = req.path.split("(");
        if (items.length != 2) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
            return;
        }

        auto strId = items[1].split(")")[0];
        int todoId = strId.to!int;

        bool found = usecase.deleteTodo(todoId);
        if (found) {
            res.statusCode = HTTPStatus.noContent;
            res.writeODataJson(Json(null));
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
        }

    }

    void getProjectTodos(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching todos for project with ID: ", req
                .params["id"]);
        int projId = req
            .params["id"].to!int;
        Json[] result;
        foreach (t; usecase.listTodos(projId)) {
            result ~= Json.emptyObject
                .set("Id", t.id)
                .set("Title", t.title)
                .set("Completed", Json(t.completed));
        }
        res.writeODataJson(Json.emptyObject
                .set("@odata.context", Json("/odata/v4/$metadata#Todos"))
                .set("value", Json(result)));
    }

    void listTodos(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching all todos");

        auto items = req.path.split("(");
        if (items.length == 2) {
            auto idStr = items[1].split(")")[0];
            int id = idStr.to!int;
            auto todo = usecase.getTodo(id);
            if (todo == Todo.init) {
                res.statusCode = HTTPStatus.notFound;
                res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
                return;
            }

            res.writeODataJson(Json.emptyObject
                    .set("@odata.context", Json("/odata/v4/$metadata#Todos/$entity"))
                    .set("Id", Json(todo.id))
                    .set("Title", Json(todo.title))
                    .set("Completed", Json(todo.completed)));
            return;
        }

        Json[] result;
        // KORREKTUR: Alle Todos auflisten ohne req.params["id"]
        foreach (t; usecase.listTodos()) {
            result ~= Json.emptyObject
                .set("Id", t.id)
                .set("Title", t.title)
                .set("Completed", Json(t.completed));
        }
        res.writeODataJson(Json.emptyObject
                .set("@odata.context", Json("/odata/v4/$metadata#Todos"))
                .set("value", Json(result)));
    }

    void getTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching todo with ID: ", req.params["id"]);

        int id = req.params["id"].to!int;
        auto todo = usecase.getTodo(id);
        if (todo == Todo.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
            return;
        }
        res.writeODataJson(todo);
    }

    void updateTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Updating todo...");
        writeln("Path info: ", req.path);

        auto items = req.path.split("(");
        if (items.length == 2) {
            auto idStr = items[1].split(")")[0];
            int todoId = idStr.to!int;
            auto todo = usecase.getTodo(todoId);
            if (todo == Todo.init) {
                res.statusCode = HTTPStatus.notFound;
                res.writeODataJson(Json.emptyObject.set("error", "Todo not found"));
                return;
            }
            auto json = req.json;
            writeln("Updating todo with ID: ", todoId, " and request body: ", json);

            todo.title = json.getString("Title", json.getString("title", todo.title));
            todo.completed = json.getBoolean("Completed", json.getBoolean("completed", todo
                    .completed));
            usecase.updateTodo(todo);
            res.writeODataJson(todo);
            return;
        }
        res.statusCode = HTTPStatus.badRequest;
        res.writeODataJson(Json.emptyObject.set("error", "Invalid request"));
    }
}
