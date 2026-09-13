module app;
import vibe.d;
import std.conv : to;
import std.process : environment;
@safe:
void main() {
    auto settings = new HTTPServerSettings;
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];
    auto router = new URLRouter;
    router.get("/api/health", &healthHandler);
    router.get("/api/chart-data", &chartDataHandler);
    // Local fallback: serve frontend files when this backend is run standalone.
    router.get("/", serveStaticFiles("../frontend/index.html"));
    router.get("*", serveStaticFiles("../frontend/"));
    listenHTTP(settings, router);
    logInfo("Chart Demo backend listening on port %s", settings.port);
    runApplication();
}
void healthHandler(HTTPServerRequest req, HTTPServerResponse res) {
    Json responseJson = Json.emptyObject;
    responseJson["status"] = Json("UP");
    responseJson["service"] = Json("chart-demo-backend");
    res.writeJsonBody(responseJson);
}
void chartDataHandler(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type";
    if (req.method == HTTPMethod.OPTIONS) {
        res.writeJsonBody(Json.emptyObject);
        return;
    }
    Json values = Json.emptyArray;
    Json row1 = Json.emptyObject;
    row1["item"] = Json("Laptop");
    row1["city"] = Json("Berlin");
    row1["sum"] = Json(42);
    values ~= row1;
    Json row2 = Json.emptyObject;
    row2["item"] = Json("Monitor");
    row2["city"] = Json("Munich");
    row2["sum"] = Json(27);
    values ~= row2;
    Json row3 = Json.emptyObject;
    row3["item"] = Json("Keyboard");
    row3["city"] = Json("Hamburg");
    row3["sum"] = Json(35);
    values ~= row3;
    Json responseJson = Json.emptyObject;
    responseJson["value"] = values;
    res.writeJsonBody(responseJson);
}
