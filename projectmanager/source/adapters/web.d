module adapters.web;

import vibe.d;
import std.conv : to;
import domain;
import application;

@safe:

class ProjectHttpController {
    private ProjectService service;

    this(ProjectService service) {
        this.service = service;
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        res.writeJsonBody(service.listProjects());
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);

        Project project;
        if (!service.getProject(id, project)) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return;
        }

        res.writeJsonBody(project);
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;

        string name = "";
        string description = "";
        Todo[] todos;

        if ("name" in body) {
            name = body["name"].get!string;
        }

        if ("description" in body) {
            description = body["description"].get!string;
        }

        if ("todos" in body && body["todos"].type == Json.Type.array) {
            todos = parseTodos(body["todos"]);
        }

        if (name.length == 0) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeJsonBody(["error": "Field 'name' is required"]);
            return;
        }

        auto created = service.createProject(name, description, todos);
        res.statusCode = HTTPStatus.created;
        res.headers["Location"] = "/api/projects/" ~ created.id.to!string;
        res.writeJsonBody(created);
    }

    void updateProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);
        auto body = req.json;

        string name = "";
        string description = "";
        Todo[] todos;

        if ("name" in body) {
            name = body["name"].get!string;
        }

        if ("description" in body) {
            description = body["description"].get!string;
        }

        if ("todos" in body && body["todos"].type == Json.Type.array) {
            todos = parseTodos(body["todos"]);
        }

        if (name.length == 0) {
            res.statusCode = HTTPStatus.badRequest;
            res.writeJsonBody(["error": "Field 'name' is required"]);
            return;
        }

        Project updated;
        if (!service.updateProject(id, name, description, todos, updated)) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return;
        }

        res.writeJsonBody(updated);
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);

        if (!service.deleteProject(id)) {
            res.statusCode = HTTPStatus.notFound;
            res.writeJsonBody(["error": "Project not found"]);
            return;
        }

        res.statusCode = HTTPStatus.noContent;
        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
    }

    private int extractId(HTTPServerRequest req) {
        string path = req.requestPath.to!string;
        auto parts = path.split("/");

        if (parts.length == 0) {
            return -1;
        }

        return parts[$ - 1].to!int;
    }

    @trusted private Todo[] parseTodos(Json todosJson) {
        Todo[] todos;

        foreach (item; todosJson) {
            int todoId = 0;
            string title = "";
            bool completed = false;

            if ("id" in item) {
                todoId = item["id"].get!int;
            }
            if ("title" in item) {
                title = item["title"].get!string;
            }
            if ("completed" in item) {
                completed = item["completed"].get!bool;
            }

            todos ~= Todo(todoId, title, completed);
        }

        return todos;
    }
}
