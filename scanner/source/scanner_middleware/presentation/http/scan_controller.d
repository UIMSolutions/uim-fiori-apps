module scanner_middleware.presentation.http.scan_controller;

import std.conv : to;
import std.string : strip;

import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

import scanner_middleware.application.services.gtt_dispatch_queue : GttDispatchItem,
    GttDispatchQueue;
import scanner_middleware.application.dto.capture_scan_command : CaptureScanCommand;
import scanner_middleware.application.usecases.capture_scan_usecase : CaptureScanUseCase;
import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : ScanRepository;

class ScanController {
    private CaptureScanUseCase m_captureScanUseCase;
    private ScanRepository m_repository;
    private GttDispatchQueue m_dispatchQueue;

    this(CaptureScanUseCase captureScanUseCase, ScanRepository repository,
            GttDispatchQueue dispatchQueue) {
        m_captureScanUseCase = captureScanUseCase;
        m_repository = repository;
        m_dispatchQueue = dispatchQueue;
    }

    void registerRoutes(URLRouter router) {
        router.post("/api/scans", &captureScan);
        router.get("/api/scans", &listScans);
        router.post("/api/gtt/retry", &retryGttQueue);
        router.get("/api/gtt/queue", &getGttQueueStatus);
        router.get("/api/health", &health);
    }

    void captureScan(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        auto command = toCaptureCommand(body);
        auto result = m_captureScanUseCase.execute(command);

        Json response = Json.emptyObject;
        response["success"] = Json(result.success);
        response["forwardedToSapGtt"] = Json(result.forwardedToSapGtt);
        response["deadLettered"] = Json(result.deadLettered);
        response["dispatchAttempts"] = Json(cast(long) result.dispatchAttempts);
        response["message"] = Json(result.message);
        if (result.success) {
            response["event"] = toJson(result.eventData);
        }

        auto statusCode = result.success ? 201 : 400;
        res.headers["Content-Type"] = "application/json";
        res.writeBody(response.toString(), statusCode, "application/json");
    }

    void listScans(HTTPServerRequest req, HTTPServerResponse res) {
        size_t limit = 100;
        if ("limit" in req.query) {
            limit = to!size_t(req.query.get("limit", "100"));
        }

        auto items = m_repository.listRecent(limit);
        Json response = Json.emptyObject;
        Json array = Json.emptyArray;
        foreach (item; items) {
            array ~= toJson(item);
        }
        response["items"] = array;
        response["count"] = Json(cast(long) items.length);

        res.headers["Content-Type"] = "application/json";
        res.writeBody(response.toString(), 200, "application/json");
    }

    void retryGttQueue(HTTPServerRequest req, HTTPServerResponse res) {
        auto dispatched = m_dispatchQueue.retryAllPending();
        Json response = Json.emptyObject;
        response["dispatched"] = Json(cast(long) dispatched);
        response["pending"] = Json(cast(long) m_dispatchQueue.getPending().length);
        response["deadLetters"] = Json(cast(long) m_dispatchQueue.getDeadLetters().length);
        res.headers["Content-Type"] = "application/json";
        res.writeBody(response.toString(), 200, "application/json");
    }

    void getGttQueueStatus(HTTPServerRequest req, HTTPServerResponse res) {
        Json response = Json.emptyObject;
        response["pending"] = toDispatchArray(m_dispatchQueue.getPending());
        response["deadLetters"] = toDispatchArray(m_dispatchQueue.getDeadLetters());
        res.headers["Content-Type"] = "application/json";
        res.writeBody(response.toString(), 200, "application/json");
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        Json response = Json.emptyObject;
        response["status"] = Json("UP");
        response["service"] = Json("scanner-middleware");
        res.headers["Content-Type"] = "application/json";
        res.writeBody(response.toString(), 200, "application/json");
    }

    private CaptureScanCommand toCaptureCommand(Json body) {
        CaptureScanCommand command;
        command.scannerId = jsonString(body, "scannerId");
        command.materialNumber = jsonString(body, "materialNumber");
        command.location = jsonString(body, "location");
        command.quantity = jsonSizeT(body, "quantity", 1);
        command.rawPayload = body.toString();

        return command;
    }

    private string jsonString(Json body, string key, string defaultValue = "") {
        if (!(key in body)) {
            return defaultValue;
        }

        auto node = body[key];
        if (node.type == Json.Type.string) {
            return node.get!string;
        }
        return node.toString();
    }

    private size_t jsonSizeT(Json body, string key, size_t defaultValue) {
        if (!(key in body)) {
            return defaultValue;
        }

        try {
            return cast(size_t) body[key].get!long;
        } catch (Exception) {
            return defaultValue;
        }
    }

    private Json toJson(ScanEvent eventData) {
        Json node = Json.emptyObject;
        node["eventId"] = Json(eventData.eventId);
        node["scannerId"] = Json(eventData.scannerId);
        node["materialNumber"] = Json(eventData.materialNumber);
        node["quantity"] = Json(cast(long) eventData.quantity);
        node["location"] = Json(eventData.location);
        node["scannedAt"] = Json(eventData.scannedAt.toISOString());
        return node;
    }

    private Json toDispatchArray(GttDispatchItem[] items) {
        Json array = Json.emptyArray;
        foreach (item; items) {
            Json entry = Json.emptyObject;
            entry["event"] = toJson(item.eventData);
            entry["attempts"] = Json(cast(long) item.attempts);
            entry["deadLettered"] = Json(item.deadLettered);
            entry["lastError"] = Json(item.lastError);
            array ~= entry;
        }
        return array;
    }
}
