import vibe.d;
import std.process : environment;
import std.conv : to;
void getHello(HTTPServerRequest req, HTTPServerResponse res)
{
    Json payload = Json.emptyObject;
    payload["message"] = "Hello Welt aus dem abgesicherten vibe.d Backend!";
    payload["timestamp"] = Clock.currTime().toISOString();
    // JWT Token aus dem Request Header auslesen (vom Approuter übergeben)
    string authHeader = req.headers.get("Authorization", "");
    if (authHeader.length > 0) {
        payload["authenticated"] = true;
    } else {
        payload["authenticated"] = false;
    }
    res.writeJsonBody(payload);
}
void main()
{
    auto settings = new HTTPServerSettings;
    ushort port = to!ushort(environment.get("PORT", "8080"));
    settings.port = port;
    settings.bindAddresses = ["0.0.0.0"];
    auto router = new URLRouter;
    router.get("/api/hello", &getHello);
    router.get("*", serveStaticFiles("public/"));
    listenHTTP(settings, router);
    runApplication();
}