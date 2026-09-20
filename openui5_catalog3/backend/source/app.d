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
    router.get("/resources/*", serveStaticFiles("/home/oz/DEV/D/UIM2026/SAP/uim-fiori-apps/public/openui5-sdk-1.148.8/"));
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
                ComponentItem("buttons", "Button", "sap.m.Button and layouts"),
                ComponentItem("labels", "Label", "sap.m.Label text descriptors"),
                ComponentItem("inputs", "Input", "sap.m.Input text fields"),
                ComponentItem("bars", "Bar", "sap.m.Bar toolbars and containers"),
                ComponentItem("checkboxes", "CheckBox", "sap.m.CheckBox selection options"),
                ComponentItem("avatars", "Avatar", "sap.m.Avatar profile and image wrappers"),
                ComponentItem("carousels", "Carousel", "sap.m.Carousel slide container"),
                ComponentItem("menus", "Menu", "sap.m.Menu and MenuButton options"),
                ComponentItem("pdfViewers", "PDF Viewer", "sap.m.PDFViewer document container"),
                ComponentItem("genericTiles", "Generic Tile", "sap.m.GenericTile dashboard cards"),
                ComponentItem("datePickers", "Date Picker", "sap.m.DatePicker calendar input control"),
                ComponentItem("lists", "List", "sap.m.List item collection display"),
                ComponentItem("trees", "Tree", "sap.m.Tree hierarchical node display"),
                ComponentItem("feedContents", "Feed Content", "sap.m.FeedContent update snippets"),
                ComponentItem("images", "Image", "sap.m.Image graphical display"),
                ComponentItem("objectNumbers", "Object Number", "sap.m.ObjectNumber financial and metric values"),
                ComponentItem("wizards", "Wizard", "sap.m.Wizard multi-step guided workflows"),
                ComponentItem("newsContents", "News Content", "sap.m.NewsContent headlines and summaries"),
                ComponentItem("slideTiles", "Slide Tile", "sap.m.SlideTile rotating dashboard cards"),
                ComponentItem("tileContents", "Tile Content", "sap.m.TileContent dashboard wrapper container")
            ]
        ),
        NamespaceItem(
            "sap_ui_table",
            "sap.ui.table",
            "Complex tabular controls with advanced grouping and aggregation",
            [
                ComponentItem("analyticalTables", "Analytical Table", "sap.ui.table.AnalyticalTable dataset controls")
            ]
        ),
        NamespaceItem(
            "sap_ui_layout",
            "sap.ui.layout",
            "Forms, grids, and layout containers",
            [
                ComponentItem("grids", "Grid Layout", "CSS Grid structures")
            ]
        ),
        NamespaceItem(
            "sap_uxap", 
            "sap.uxap (UX Extended Library)", 
            "Object page layout and navigation components",
            [
                ComponentItem("breadcrumbs", "Bread Crumbs", "sap.uxap.BreadCrumbs hierarchical navigation"),
                ComponentItem("objectPageHeaders", "Object Page Header", "sap.uxap.ObjectPageHeader executive banner") // <-- Added here
            ]
        )
    ];
    res.writeJsonBody(namespaces);
}
