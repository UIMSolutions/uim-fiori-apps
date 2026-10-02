module uim.fiori.manifest.configs.config;

import uim.fiori;

@safe:
struct DataSource {
    string name;
    string uri;
    string type;
    string odataVersion;
    string[string] settings;

    Json toJson() const {
        auto json = Json.emptyObject;
        if (!name.empty) {
            json.set("name", name);
        }
        if (!uri.empty) {
            json.set("uri", uri);
        }
        if (!type.empty) {
            json.set("type", type);
        }
        if (!odataVersion.empty) {
            json.set("odataVersion", odataVersion);
        }
        auto jsonSettings = Json.emptyObject;
        foreach(key, value; settings) {
            jsonSettings.set(key, value);
        }
        json.set("settings", jsonSettings);
        return json;
    }
}
struct View {
    string name;
    string type;
    string async;
    string id;
}
struct Resource {
    string name;
    string[string] settings;
}
struct Model {
    string name;
    string dataSource;
    bool preload;
    string[string] settings;
}
/// Configuration structure for all user-selectable options.
struct ManifestConfig {
    SapAppConfig app = SapAppConfig();
    SapUiConfig ui = SapUiConfig();
    SapUi5Config ui5 = SapUi5Config();
    // sap.ui5 specific configuration
    View[] views              = [];          
    string[string] libs;
    string minUI5Version      = "1.120.0";
    string rootViewName       = ""; // wird ggf. aus appId abgeleitet
    string rootViewType       = "XML";
    string rootViewId         = "app";
    string icon               = "sap-icon://Fiori2/F0002";
    string favIcon            = "";
    string themeName          = "sap_horizon";
    string outputPath         = "manifest.json";
    string flexibleColumnLayout = "";
    Resource[] resources        = [];
    Model[] models              = [];
    bool withRouting          = false;
    bool withOData            = false;
    string odataUri           = "/sap/opu/odata/sap/YOUR_SRV/";
    string odataModelName     = "";
    string[] extraLibs        = [];
    bool phoneSupport         = true;
    bool tabletSupport        = true;
    bool desktopSupport       = true;
    bool prettyPrint          = true;
    bool writeI18n            = true;
    bool interactive          = false;
    bool[string] deviceTypes;

    Json toJson() const {
        auto result = Json.emptyObject;
        result.set("_version", "1.0");
        result.set("sap.app", app.toJson());
        result.set("sap.ui", Json.emptyObject);

        auto json = Json.emptyObject;
        // Populate the JSON object with the manifest configuration data
        json.set("sap.app", app.toJson());
        json.set("sap.ui", Json.emptyObject);
        result.set("sap.ui5", json);
        return result;
    }
}
