module adapters.web;

import vibe.d;
import domain;
import adapters.odata_dto;
import std.algorithm : filter;
import std.array : array;
import std.regex : regex, matchFirst;
import uim.framework;

@safe:
class ODataTaskController {
    private TaskService service;
    private string serviceRoot = "/odata/v4/TaskService";

    this(TaskService service) {
        this.service = service;
    }

    // Hilfsmethode: Garantiert, dass OData-Header bei JEDER Antwort gesetzt sind
    private void writeODataJson(T)(HTTPServerResponse res, T data, HTTPStatus status = HTTPStatus
            .ok) {
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeJsonBody(data, status);
    }

    // GET /odata/v4/TaskService/Tasks
    void getTasks(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("GET /odata/v4/TaskService/Tasks");

        auto tasks = service.getAllTasks();
        ODataEntity[] entities;
        foreach (t; tasks) {
            entities ~= t.toOData();
        }

        ODataCollection responsePayload = {
            odataContext: serviceRoot ~ "/$metadata#Tasks",
            value: entities
        };

        writeODataJson(res, responsePayload);
    }

    // GET /odata/v4/TaskService/Tasks('id')
    void getTask(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("GET /odata/v4/TaskService/Tasks('id')");

        string id = extractKey(req.params.get("id", req.requestURL));
        auto task = service.findById(id);

        if (task == TodoTask.init) {
            writeODataJson(res, ["error": "Not found"], HTTPStatus.notFound);
            return;
        }

        writeODataJson(res, task.toOData(serviceRoot ~ "/$metadata#Tasks/$entity"));
    }

    // POST /odata/v4/TaskService/Tasks
    void createTask(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("POST /odata/v4/TaskService/Tasks");

        auto bodyJson = req.json;
        string title = bodyJson["title"].get!string;
        string description = bodyJson.hasKey("description") ? bodyJson["description"].get!string
            : "";

        auto newTask = service.createTask(title, description);
        auto odataEntity = newTask.toOData(serviceRoot ~ "/$metadata#Tasks/$entity");

        res.headers["Location"] = format("%s/Tasks('%s')", serviceRoot, newTask.id);
        writeODataJson(res, odataEntity, HTTPStatus.created);
    }

    // PATCH /odata/v4/TaskService/Tasks('id')
    void updateTask(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("PATCH /odata/v4/TaskService/Tasks('id')");

        // 1. Key aus der URL extrahieren
        string id = extractKey(req.params.get("key", req.requestURL));

        // 2. Erforderlich: Lade den bestehenden Task aus der Datenbank/Domain
        auto currentTask = service.findById(id);
        if (currentTask == TodoTask.init) {
            writeODataJson(res, ["error": "Task not found"], HTTPStatus.notFound);
            return;
        }

        auto bodyJson = req.json;

        string title = bodyJson.hasKey("title")
            ? bodyJson["title"].get!string : currentTask.title;

        string description = bodyJson.hasKey("description")
            ? bodyJson["description"].get!string : currentTask.description;

        bool isCompleted = bodyJson.hasKey("isCompleted")
            ? bodyJson["isCompleted"].get!bool : currentTask.isCompleted;

        auto updated = service.updateTask(id, title, description, isCompleted);
        writeODataJson(res, updated.toOData(serviceRoot ~ "/$metadata#Tasks/$entity"), HTTPStatus
                .ok);
    }

    // DELETE /odata/v4/TaskService/Tasks('id')
    void deleteTask(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("DELETE /odata/v4/TaskService/Tasks('id')");

        res.headers["OData-Version"] = "4.0";
        string id = extractKey(req.params.get("key", req.requestURL));
        service.deleteTask(id);
        res.statusCode = HTTPStatus.noContent;

        writeODataJson(res, ["message": "Deleted"], HTTPStatus.noContent);
    }

    // OData Metadata Document ($metadata)
    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("GET /odata/v4/TaskService/$metadata");

        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/xml;charset=utf-8";

        enum xmlMetadata = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="TaskService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Task">
        <Key><PropertyRef Name="id"/></Key>
        <Property Name="id" Type="Edm.String" Nullable="false"/>
        <Property Name="title" Type="Edm.String"/>
        <Property Name="description" Type="Edm.String"/>
        <Property Name="isCompleted" Type="Edm.Boolean"/>
        <Property Name="createdAt" Type="Edm.DateTimeOffset"/>
      </EntityType>
      <EntityContainer Name="EntityContainer">
        <EntitySet Name="Tasks" EntityType="TaskService.Task"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;

        res.writeBody(xmlMetadata);
    }

    private string extractKey(string rawKey) {
        auto m = matchFirst(rawKey, regex(`'([^']+)'`));
        return m.empty ? rawKey : m[1];
    }
}
