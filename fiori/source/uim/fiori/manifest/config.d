module uim.fiori.manifest.config;
struct DataSource {
    string name;
    string uri;
    string type;
    string odataVersion;
    string[string] settings;
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
struct model {
    string name;
    string dataSource;
    bool preload;
    string[string] settings;
}
/// Configuration structure for all user-selectable options.
struct ManifestConfig {
    string appId              = "com.mycompany.myapp";
    string appTitle           = "{{appTitle}}";
    string appSubtitle        = "{{appSubtitle}}";
    string appType            = "application"; // "application", "library" or "component"
    string appDescription     = "An SAP UI5 application";
    string appVersion         = "1.0.0";
    string appI18NUrl         = "i18n/i18n.properties";
    string[] appI18NLocales   = ["", "en"];
    string[] appEmbeds;
    string appEmbeddedBy;
    DataSource[] dataSources = [];
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
    model[] models              = [];
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
}