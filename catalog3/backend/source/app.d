import vibe.d;

struct ComponentItem {
    string id;
    string title;
    string description;
}

void main() {
    auto router = new URLRouter;
    
    router.get("/api/components", &getComponents);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["127.0.0.1"];
    
    listenHTTP(settings, router);
    logInfo("Server running on http://127.0.0.1:8080/");
    runApplication();
}

void getComponents(HTTPServerRequest req, HTTPServerResponse res) {
    ComponentItem[] items = [
        ComponentItem("buttons", "Buttons", "sap.m.Button and layouts"),
        ComponentItem("inputs", "Inputs", "Forms and data entry")
    ];
    res.writeJsonBody(items);
}