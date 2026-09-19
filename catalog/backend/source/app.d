import vibe.d;

struct ComponentItem {
    string id;
    string title;
    string description;
}

void main() {
    auto router = new URLRouter;
    
    // API endpoint for the master list
    router.get("/api/components", &getComponents);
    
    // Serve the UI5 application (assuming files are in a "public" folder)
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    
    listenHTTP(settings, router);
    runApplication();
}

void getComponents(HTTPServerRequest req, HTTPServerResponse res) {
    ComponentItem[] items = [
        ComponentItem("buttons", "Buttons", "sap.m.Button and related controls"),
        ComponentItem("inputs", "Input Controls", "Data entry components"),
        ComponentItem("charts", "MicroCharts", "Analytical data visualizations")
    ];
    res.writeJsonBody(items);
}