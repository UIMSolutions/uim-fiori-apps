module uim.fiori.manifest.generator;
/**
 * SAP UI5 manifest.json generator
 * ================================
 * A D command line program that provides a complete, valid
 * SAP UI5 manifest.json (Descriptor v2) generated.
 *
 * Compile:
 * dmd manifest_generator.d -of=ui5manifest
 * # or with ldc2:
 * ldc2 manifest_generator.d -of=ui5manifest
 *
 * Example calls:
 * ./ui5manifest --id com.mycompany.myapp --title "My App"
 * ./ui5manifest --id com.acme.orders --title "Orders" \
 * --desc "Order management app" --with-odata --with-routing \
 * --odata-uri /sap/opu/odata/sap/ZORDERS_SRV/ \
 * --min-ui5 1.120.0 --output ./webapp/manifest.json
 *
 * Calling without arguments starts an interactive dialog.
 */
// import std.stdio;
// import std.json;
// import std.getopt;
// import std.file : write, mkdirRecurse, exists;
// import std.path : dirName, buildPath;
// import std.string : strip, split, join, replace, empty, toLower;
// import std.array : array, appender;
// import std.algorithm : map, filter;
// import std.conv : to;
// import std.format : format;
import uim.fiori;
/// Derives the namespace path from the app ID (e.g. "com.mycompany.myapp").
string namespaceFromId(string id) {
    return id.replace(".", "/");
}
/// Baut das sap.app-Segment.
Json buildSapApp(ref const ManifestConfig cfg) {
    string semObj = cfg.app.id.split(".")[$ - 1];
    Json inbounds = Json.emptyObject;
    Json inbound = [
        "signature": Json([
            "parameters": Json.emptyObject,
            "additionalParameters": Json("allowed")
        ]),
        "semanticObject": Json(semObj),
        "action": Json("display"),
        "title": Json("{{appTitle}}"),
    ];
    inbounds[semObj ~ "-display"] = inbound;
    Json crossNav = Json.emptyObject;
    crossNav["inbounds"] = inbounds;
    Json app = Json.emptyObject
        .set("id", Json(cfg.app.id))
        .set("type", Json("application"))
        .set("i18n", Json("i18n/i18n.properties"))
        // .set("applicationVersion", Json.emptyObject.set("version", Json(cfg.app.version_)))
        .set("title", Json("{{appTitle}}"))
        .set("description", Json("{{appDescription}}"));
    Json sourceTemplate = Json.emptyObject
        .set("id", Json("@sap/generator-fiori"))
        .set("version", Json("1.0.0"));
    app["sourceTemplate"] = sourceTemplate;
    if (cfg.withOData) {
        string modelName = cfg.odataModelName.strip.empty ? "mainService" : cfg.odataModelName;
        Json dataSources = Json.emptyObject;
        Json mainSvc = Json.emptyObject
            .set("uri", Json(cfg.odataUri))
            .set("type", Json("OData"));
        mainSvc["settings"] = Json.emptyObject
            .set("odataVersion", Json("2.0"))
            .set("localUri", Json("localService/metadata.xml"));
        dataSources[modelName] = mainSvc;
        app["dataSources"] = dataSources;
    }
    app["crossNavigation"] = crossNav;
    return app;
}
/// Build the sap.ui segment (Icons, Device Types, Themes).
Json buildSapUi(ref const ManifestConfig cfg) {

    Json icons = Json.emptyObject.set("icon", Json(cfg.icon));
    if (!cfg.favIcon.strip.empty)
        icons.set("favIcon", Json(cfg.favIcon));
    
    Json deviceTypes = Json.emptyObject
        .set("desktop", Json(cfg.desktopSupport))
        .set("tablet", Json(cfg.tabletSupport))
        .set("phone", Json(cfg.phoneSupport));

    return Json.emptyObject
        .set("technology", "UI5")
        .set("icons", icons.toJson)
        .set("deviceTypes", deviceTypes);
        // .set("supportedThemes", ["sap_horizon", "sap_horizon_dark", "sap_fiori_3"]);
}
///
unittest {
    auto cfg = ManifestConfig();
    cfg.app.id = "my.app.id";
    // cfg.app.version_ = "1.0.0";
    cfg.icon = "icon.png";
    cfg.favIcon = "favicon.ico";
    cfg.desktopSupport = true;
    cfg.tabletSupport = true;
    cfg.phoneSupport = true;
    // cfg.supportedThemes = ["sap_horizon", "sap_horizon_dark", "sap_fiori_3"];
    cfg.rootViewName = "my.app.view.App";
    cfg.rootViewType = "XML";
    cfg.rootViewId = "app";
    cfg.minUI5Version = "1.96.0";
    cfg.extraLibs = [];
    cfg.withOData = true;
    cfg.odataModelName = "mainService";
    cfg.odataUri = "/sap/odata/service";
    cfg.flexibleColumnLayout = "";

    // assert(cfg.app.id == "my.app.id");
    // assert(cfg.app.version_ == "1.0.0");
    // assert(cfg.icon == "icon.png");
    // assert(cfg.favIcon == "favicon.ico");
    // assert(cfg.desktopSupport);
    // assert(cfg.tabletSupport);
    // assert(cfg.phoneSupport);
    // assert(cfg.supportedThemes == ["sap_horizon", "sap_horizon_dark", "sap_fiori_3"]);
    // assert(cfg.rootViewName == "my.app.view.App");
    // assert(cfg.rootViewType == "XML");
    // assert(cfg.rootViewId == "app");
    // assert(cfg.minUI5Version == "1.96.0");
    // assert(cfg.extraLibs == []);
    // assert(cfg.withOData);
    // assert(cfg.odataModelName == "mainService");
    // assert(cfg.odataUri == "/sap/odata/service");
    // assert(cfg.flexibleColumnLayout == "");

    auto ui = buildSapUi(cfg);
    // assert(ui.get("icon") == cfg.icon);
    // assert(ui.get("favIcon") == cfg.favIcon);
    // assert(ui["desktopSupport"] == cfg.desktopSupport);
    // assert(ui["tabletSupport"] == cfg.tabletSupport);
    // assert(ui["phoneSupport"] == cfg.phoneSupport);
    // assert(ui["supportedThemes"] == cfg.supportedThemes);
    // assert(ui["rootView"]["viewName"] == cfg.rootViewName);
    // assert(ui["rootView"]["type"] == cfg.rootViewType);
    // assert(ui["rootView"]["id"] == cfg.rootViewId);
    // assert(ui["dependencies"]["minUI5Version"] == cfg.minUI5Version);
    // foreach (lib; cfg.extraLibs) {
        // if (!lib.strip.empty)
            // assert(ui["dependencies"]["libs"][lib.strip] == Json.emptyObject);
    // }
    // assert(ui["contentDensities"]["compact"] == true);
    // assert(ui["contentDensities"]["cozy"] == true);

    writeln(ui.toPrettyString);
}

/// Build the sap.ui5 segment: rootView, dependencies, models, routing.
Json buildSapUi5(ref const ManifestConfig cfg) {
    Json ui5 = Json.emptyObject;
    string rootViewName = cfg.rootViewName.strip.empty
        ? namespaceFromId(cfg.app.id) ~ ".view.App" : cfg.rootViewName;
    /// Build the root view configuration.
    ui5["rootView"] = Json.emptyObject
        .set("viewName", Json(rootViewName))
        .set("type", Json(cfg.rootViewType))
        .set("id", Json(cfg.rootViewId));
    Json dependencies = Json.emptyObject
        .set("minUI5Version", Json(cfg.minUI5Version));
    Json libs = Json.emptyObject
        .set("sap.ui.core", Json.emptyObject)
        .set("sap.m", Json.emptyObject)
        .set("sap.f", Json.emptyObject)
        .set("sap.ui.layout", Json.emptyObject);
    foreach (lib; cfg.extraLibs) {
        if (!lib.strip.empty)
            libs[lib.strip] = Json.emptyObject;
    }
    dependencies["libs"] = libs;
    ui5["dependencies"] = dependencies;
    Json contentDensities = Json.emptyObject
        .set("compact", Json(true))
        .set("cozy", Json(true));
    ui5["contentDensities"] = contentDensities;
    Json models = Json.emptyObject;
    models["i18n"] = Json.emptyObject
        .set("type", Json("sap.ui.model.resource.ResourceModel"))
        .set("settings", Json.emptyObject
            .set("bundleName", Json(namespaceFromId(cfg.app.id) ~ ".i18n.i18n"))
        );
    if (cfg.withOData) {
        string modelName = cfg.odataModelName.strip.empty ? "" : cfg.odataModelName;
        // Standard-Datenmodell (leerer Name = Default-Modell) referenziert die dataSource.
        Json odataModel = Json.emptyObject
            .set("dataSource", Json(cfg.odataModelName.strip.empty ? "mainService" : cfg.odataModelName))
            .set("preload", Json(true))
            .set("settings", Json.emptyObject
                .set("defaultBindingMode", Json("TwoWay"))
                .set("defaultCountMode", Json("Inline"))
            );
        models[""] = odataModel;
    }
    ui5["models"] = models;
    Json resources = Json.emptyObject;
    resources["css"] = Json.emptyArray;
    resources["css"] ~= Json.emptyObject.set("uri", Json("css/style.css"));
    ui5["resources"] = resources;
    if (!cfg.flexibleColumnLayout.strip.empty) {
        ui5["routing"] = buildRoutingWithFCL(cfg);
    } else if (cfg.withRouting) {
        ui5["routing"] = buildRouting(cfg);
    }
    return ui5;
}
/// Simple standard routing configuration with an overview view.
Json buildRouting(ref const ManifestConfig cfg) {
    string ns = namespaceFromId(cfg.app.id);
    Json config = Json.emptyObject
        .set("routerClass", Json("sap.m.routing.Router"))
        .set("type", Json("View"))
        .set("viewType", Json("XML"))
        .set("path", Json(ns ~ ".view"))
        .set("controlId", Json("app"))
        .set("controlAggregation", Json("pages"))
        .set("async", Json(true))
        .set("clearControlAggregation", Json(false));
    Json routes = Json.emptyArray;
    routes ~= Json.emptyObject
            .set("pattern", Json(""))
            .set("name", Json("home"))
            .set("target", Json("home"));
    Json targets = Json.emptyObject
        .set("home", Json.emptyObject
                .set("viewId", Json("home"))
                .set("viewName", Json("Home")));
    return Json.emptyObject
        .set("config", config)
        .set("routes", routes)
        .set("targets", targets);
}
/// Routing configuration with sap.f.FlexibleColumnLayout (List-Detail pattern).
Json buildRoutingWithFCL(ref const ManifestConfig cfg) {
    string ns = namespaceFromId(cfg.app.id);
    Json config = Json.emptyObject
        .set("routerClass", Json("sap.f.routing.Router"))
        .set("viewType", Json("XML"))
        .set("path", Json(ns ~ ".view"))
        .set("controlId", Json("flexibleColumnLayout"))
        .set("controlAggregation", Json("beginColumnPages"))
        .set("async", Json(true))
        .set("flexibleColumnLayout", Json.emptyObject
                .set("defaultTwoColumnLayoutType", Json(cfg.flexibleColumnLayout))
        );
    Json routes = Json.emptyArray;
    routes ~= Json.emptyObject
        .set("pattern", Json(""))
        .set("name", Json("list"))
        .set("target", ["list"].toJson);
    routes ~= Json.emptyObject
        .set("pattern", Json("detail/{objectId}"))
        .set("name", Json("detail"))
        .set("target", ["list", "detail"].toJson);
    Json targets = Json.emptyObject
        .set("list", Json.emptyObject
                .set("viewId", Json("list"))
                .set("viewName", Json("List"))
                .set("controlAggregation", Json("beginColumnPages"))
        )
        .set("detail", Json.emptyObject
                .set("viewId", Json("detail"))
                .set("viewName", Json("Detail"))
                .set("controlAggregation", Json("midColumnPages"))
        );
    return Json.emptyObject
        .set("config", config)
        .set("routes", routes)
        .set("targets", targets);
}
/// Build the complete manifest.json as Json.
Json buildManifest(ref const ManifestConfig cfg) {
    return Json.emptyObject
        .set("_version", Json("1.60.0"))
        .set("sap.app", buildSapApp(cfg))
        .set("sap.ui", buildSapUi(cfg))
        .set("sap.ui5", buildSapUi5(cfg))
        .set("sap.fiori", Json.emptyObject
                .set("registrationIds", Json.emptyArray)
                .set("archeType", Json("transactional"))
        );
}
/// Write a minimal i18n.properties file according to the configuration.
void writeI18nFile(ref const ManifestConfig cfg) {
    string outDir = dirName(cfg.outputPath);
    string i18nDir = buildPath(outDir == "." ? "." : outDir, "i18n");
    mkdirRecurse(i18nDir);
    string i18nPath = buildPath(i18nDir, "i18n.properties");
    auto content = appender!string;
    content ~= "# i18n resource bundle - generiert von manifest_generator\n";
    // content ~= format("appTitle=%s\n", cfg.appTitle);
    // content ~= format("appDescription=%s\n", cfg.appDescription);
    std.file.write(i18nPath, content.data);
    stderr.writeln("i18n-Datei geschrieben nach: ", i18nPath);
}
/// Interactive dialog if the program is called without arguments.
ManifestConfig runInteractive() {
    ManifestConfig cfg;
    string ask(string prompt, string def) {
        writef("%s [%s]: ", prompt, def);
        stdout.flush();
        string line = readln();
        line = line is null ? "" : line.strip;
        return line.empty ? def : line;
    }
    bool askBool(string prompt, bool def) {
        string d = def ? "J/n" : "j/N";
        writef("%s [%s]: ", prompt, d);
        stdout.flush();
        string line = readln();
        line = line is null ? "" : line.strip.toLower;
        if (line.empty)
            return def;
        return line == "j" || line == "y" || line == "ja" || line == "yes";
    }
    writeln("=== SAP UI5 manifest.json Generator (interaktiv) ===");
    // cfg.app.id = ask("App-ID (z.B. com.mycompany.myapp)", cfg.app.id);
    // cfg.appTitle = ask("App-Titel", cfg.appTitle);
    // cfg.appDescription = ask("App-Beschreibung", cfg.app.description);
    // cfg.app.version_ = ask("App-Version", cfg.app.version_);
    cfg.minUI5Version = ask("Minimale UI5-Version", cfg.minUI5Version);
    cfg.withOData = askBool("OData-Datenquelle einbinden?", cfg.withOData);
    if (cfg.withOData)
        cfg.odataUri = ask("OData-Service-URI", cfg.odataUri);
    cfg.withRouting = askBool("Einfaches Routing einbinden?", cfg.withRouting);
    cfg.outputPath = ask("Ausgabepfad", cfg.outputPath);
    return cfg;
}
void printUsage() {
    writeln(`SAP UI5 manifest.json Generator (Dlang)
Verwendung:
  ui5manifest [Optionen]
  ui5manifest                 (ohne Optionen -> interaktiver Modus)
Optionen:
  --id              App-ID, z.B. com.mycompany.myapp
  --title           App-Titel
  --desc            App-Beschreibung
  --app-version     App-Version (Standard: 1.0.0)
  --min-ui5         Minimale UI5-Version (Standard: 1.120.0)
  --root-view       Name der Root-View (Standard: <namespace>.view.App)
  --root-view-id    ID der Root-View (Standard: app)
  --icon            sap-icon:// URI
  --with-routing    Einfaches Routing hinzufügen
  --with-odata      OData-V2-Datenquelle + Standardmodell hinzufügen
  --odata-uri       URI des OData-Service
  --odata-model     Name des OData-Modells (leer = Default-Modell)
  --fcl             FlexibleColumnLayout-Typ (z.B. TwoColumnsMidExpanded) -> aktiviert FCL-Routing
  --lib             Zusätzliche UI5-Bibliothek (wiederholbar), z.B. --lib sap.ui.table
  --no-phone        Phone-Unterstützung deaktivieren
  --no-tablet       Tablet-Unterstützung deaktivieren
  --no-desktop      Desktop-Unterstützung deaktivieren
  --no-i18n         Keine i18n.properties-Datei erzeugen
  --compact         JSON kompakt statt eingerückt ausgeben
  --output          Zielpfad der manifest.json (Standard: manifest.json)
  --help            Diese Hilfe anzeigen
`);
}
// int main(string[] args) {
//     ManifestConfig cfg;
//     bool showHelp = false;
//     if (args.length == 1) {
//         cfg = runInteractive();
//     } else {
//         try {
//             auto helpInfo = getopt(args,
//                 "id", &cfg.app.id,
//                 "title", &cfg.appTitle,
//                 "desc", &cfg.appDescription,
//                 "app-version", &cfg.app.version_,
//                 "min-ui5", &cfg.minUI5Version,
//                 "root-view", &cfg.rootViewName,
//                 "root-view-id", &cfg.rootViewId,
//                 "icon", &cfg.icon,
//                 "with-routing", &cfg.withRouting,
//                 "with-odata", &cfg.withOData,
//                 "odata-uri", &cfg.odataUri,
//                 "odata-model", &cfg.odataModelName,
//                 "fcl", &cfg.flexibleColumnLayout,
//                 "lib", &cfg.extraLibs,
//                 "no-phone", { cfg.phoneSupport = false; },
//                 "no-tablet", { cfg.tabletSupport = false; },
//                 "no-desktop", { cfg.desktopSupport = false; },
//                 "no-i18n", { cfg.writeI18n = false; },
//                 "compact", { cfg.prettyPrint = false; },
//                 "output", &cfg.outputPath,
//             );
//             if (helpInfo.helpWanted) {
//                 printUsage();
//                 return 0;
//             }
//         } catch (Exception e) {
//             stderr.writeln("Fehler beim Parsen der Argumente: ", e.msg);
//             printUsage();
//             return 1;
//         }
//     }
//     if (cfg.app.id.strip.empty) {
//         stderr.writeln("Fehler: --id darf nicht leer sein.");
//         return 1;
//     }
//     Json manifest = buildManifest(cfg);
//     string jsonOut = cfg.prettyPrint ? manifest.toPrettyString() : manifest.toString();
//     string outDir = dirName(cfg.outputPath);
//     if (outDir != "." && !exists(outDir))
//         mkdirRecurse(outDir);
//     std.file.write(cfg.outputPath, jsonOut ~ "\n");
//     writeln("manifest.json erfolgreich geschrieben nach: ", cfg.outputPath);
//     if (cfg.writeI18n)
//         writeI18nFile(cfg);
//     return 0;
// }
