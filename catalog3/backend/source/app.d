import vibe.d;

struct ComponentItem {
    string id;
    string title;
    string description;
}

struct NamespaceItem {
    string id;
    string name;
    string description;
    ComponentItem[] components;
}

void main() {
    auto router = new URLRouter;
    
    router.get("/api/components", &getNamespaces);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["127.0.0.1"];
    
    listenHTTP(settings, router);
    logInfo("Server running on http://127.0.0.1:8080/");
    runApplication();
}

void getNamespaces(HTTPServerRequest req, HTTPServerResponse res) {
    NamespaceItem[] namespaces = [
        NamespaceItem(
            "sap_m", 
            "sap.m (Main Library)", 
            "Controls for mobile and desktop applications",
            [
                ComponentItem("buttons", "Buttons", "sap.m.Button and layouts"),
                ComponentItem("inputs", "Inputs", "sap.m.Input and related controls"),
                ComponentItem("labels", "Labels", "sap.m.Label and related controls"),
            ]
        ),
            NamespaceItem(
                "sap_ui_layout", 
                "sap.ui.layout", 
                "Forms, grids, and layout containers",
                [
                    ComponentItem("grids", "Grid Layout", "CSS Grid structures")
                ]
        )
    ];
    res.writeJsonBody(namespaces);
}