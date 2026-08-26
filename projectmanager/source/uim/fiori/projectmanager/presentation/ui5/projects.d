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
    private int nextTodoId = 1;

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
        router.delete_("/odata/v4/Projects\\(:id\\)", &deleteProject);

        router.get("/odata/v4/Todos", &listTodos);
        router.post("/odata/v4/Todos", &createTodo);
        router.get("/odata/v4/Todos(:id)", &getTodo);
        router.patch("/odata/v4/Todos(:id)", &updateTodo);
        router.delete_("/odata/v4/Todos\\(:id\\)", &deleteTodo);

        // Navigation Property: /Projects(1)/Todos
        router.get("/odata/v4/Projects(:id)/Todos", &getProjectTodos);
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
        <Property Name="ProjectId" Type="Edm.Int32" Nullable="false" />
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

        res.writeJsonBody(Json.emptyObject
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

        Json[] result;
        foreach (p; usecase.listProjects()) {
            result ~= Json.emptyObject
                .set("Id", p.id)
                .set("Name", p.name)
                .set("Description", p.description);
        }
        res.writeJsonBody([
            "@odata.context": Json("/odata/v4/$metadata#Projects"),
            "value": Json(result)
        ]);
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching project with ID: ", req.params["id"]);

        int id = req.params["id"].to!int;
        auto project = usecase.getProject(id);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return; // KORREKTUR: Abbruch nach 404
        }
        res.writeJsonBody(project);
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Creating project with request body: ", req.json);

        auto json = req.json;
        Project newProj = Project();
        // KORREKTUR: PascalCase für OData oder Abfangen fehlender Keys
        newProj.name = json.getString("Name", json.getString("name", ""));
        newProj.description = json.getString("Description", json.getString("description", ""));
        newProj.todos = null;

        usecase.createProject(newProj.name, newProj.description, newProj.todos);
        res.statusCode = HTTPStatus.created;
        res.writeJsonBody(Json.emptyObject
                .set("@odata.context", Json("/odata/v4/$metadata#Projects/$entity"))
                .set("Id", Json(newProj.id))
                .set("Name", Json(newProj.name))
                .set("Description", Json(newProj.description)));
    }

    void updateProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Updating project with ID: ", req.params["id"], " and request body: ", req.json);

        int id = req.params["id"].to!int;
        auto json = req.json;

        auto project = usecase.getProject(id);
        if (project != Project.init) {
            project.name = json.getString("Name", json.getString("name", project.name));
            project.description = json.getString("Description", json.getString("description", project.description));
            usecase.updateProject(id, project.name, project.description, project.todos);
            res.writeJsonBody(project);
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
        }
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Deleting project with ID: ", req.params["id"]);

        int id = req.params["id"].to!int;
        bool found = usecase.deleteProject(id);

        if (found) {
            res.statusCode = HTTPStatus.noContent;
            res.writeBody(""); 
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
        }
    }

    // --- Todo-Endpoints ---
    void createTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Creating todo with request body: ", req.json);

        auto json = req.json;

        // KORREKTUR: ProjectId aus Request-Body lesen, da in Route kein :id
        int projId = json.getInteger("ProjectId", 0);

        auto project = usecase.getProject(projId);
        if (project == Project.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return;
        }

        Todo newTodo;
        newTodo.id = nextTodoId++;
        newTodo.title = json.getString("Title", json.getString("title", ""));
        newTodo.completed = false;

        project.todos ~= newTodo;
        usecase.updateProject(projId, project.name, project.description, project.todos);
        
        res.statusCode = HTTPStatus.created;
        res.writeJsonBody(Json.emptyObject
            .set("@odata.context", Json("/odata/v4/$metadata#Todos/$entity"))
            .set("Id", Json(newTodo.id))
            .set("ProjectId", Json(projId))
            .set("Title", Json(newTodo.title))
            .set("Completed", Json(newTodo.completed)));
    }

    void deleteTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Deleting todo with ID: ", req.params["id"]);

        // KORREKTUR: Route hat nur :id
        int todoId = req.params["id"].to!int;

        bool found = usecase.deleteTodo(todoId);
        if (found) {
            res.statusCode = HTTPStatus.noContent;
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Todo not found"]);
        }
    }

    void getProjectTodos(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching todos for project with ID: ", req.params["id"]);

        int projId = req.params["id"].to!int;
        Json[] result;
        foreach (t; usecase.listTodos(projId)) {
            result ~= Json.emptyObject
                .set("Id", t.id)
                .set("ProjectId", projId)
                .set("Title", t.title)
                .set("Completed", t.completed);
        }
        res.writeJsonBody([
            "@odata.context": Json("/odata/v4/$metadata#Todos"),
            "value": Json(result)
        ]);
    }

    void listTodos(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching all todos");

        Json[] result;
        // KORREKTUR: Alle Todos auflisten ohne req.params["id"]
        foreach (t; usecase.listTodos()) {
            result ~= Json.emptyObject
                .set("Id", t.id)
                .set("Title", t.title)
                .set("Completed", t.completed);
        }
        res.writeJsonBody([
            "@odata.context": Json("/odata/v4/$metadata#Todos"),
            "value": Json(result)
        ]);
    }

    void getTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Fetching todo with ID: ", req.params["id"]);

        int id = req.params["id"].to!int;
        auto todo = usecase.getTodo(id);
        if (todo == Todo.init) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Todo not found"]);
            return;
        }
        res.writeJsonBody(todo);
    }

    void updateTodo(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Updating todo with ID: ", req.params["id"], " and request body: ", req.json);

        int id = req.params["id"].to!int;
        auto json = req.json;

        auto todo = usecase.getTodo(id);
        if (todo != Todo.init) {
            todo.title = json.getString("Title", json.getString("title", todo.title));
            todo.completed = json.getBoolean("Completed", json.getBoolean("completed", todo.completed));
            usecase.updateTodo(todo);
            res.writeJsonBody(todo);
        } else {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Todo not found"]);
        }
    }
}