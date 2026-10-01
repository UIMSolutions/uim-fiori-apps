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

struct SapAppConfig {
    string id; /// The unique identifier of the application.
    string type; /// The type of the application (e.g., "application", "library", "component").
    string i18n; /// The path to the i18n properties file.
    string applicationVersion; /// The version of the application.
    string sourceTemplate; /// The source template used to generate the application.
    string embeds; /// The identifiers of the applications that this application embeds.
    string embeddedBy; /// The identifier of the application that embeds this application.
    string title; /// The title of the application.
    string subtitle; /// The subtitle of the application.
    string shortTitle; /// The short title of the application.
    string info; /// Additional information about the application.
    string description; /// The description of the application.
    string[] tags; /// An array of keywords; either text or a language-dependent entry to be specified via {{…}} syntax, for example "keywords": ["{{keyWord1}}","{{keyWord2}}"].
    string[] ach; /// Application component hierarchy (SAP's component names for bug reports); attribute is mandatory for SAP apps, but is not used so far for apps developed outside SAP.   
    DataSource[string] dataSources; /// The data sources used by the application.
    CdsView[] cdsViews; /// The CDS views used by the application.
    bool offline; /// Indicates whether the application supports offline mode.
    string sourceTemplate; /// The source template used to generate the application.
    string[] openSourceComponents; /// The open source components used by the application.
    string provider; /// The provider of the application.
    CrossNavigation[string] crossNavigations; /// The cross-navigation configuration of the application.
    Resource[] resources; /// The resources used by the application.

    Json toJson() const {
        auto jsonDataSourcesJson = Json.emptyObject;
        foreach(key, ds; dataSources) {
            jsonDataSourcesJson[key] = ds.toJson();
        }

        auto json = Json.emptyObject
        .set("id",id)
        .set("type",type)
        .set("i18n",i18n)
        .set("applicationVersion", Json.emptyObject.set("version", applicationVersion))
        .set("sourceTemplate",sourceTemplate)
        .set("embeds",embeds)
        .set("embeddedBy",embeddedBy)
        .set("title",title)
        .set("subtitle",subtitle)
        .set("shortTitle",shortTitle)
        .set("info",info)   
        .set("description", description)
        .set("tags",tags)
        .set("ach", ach)
        .set("dataSources", jsonDataSourcesJson)
        .set("cdsViews",cdsViews)
        .set("offline", offline)
        .set("openSourceComponents",openSourceComponents)
        .set("provider",provider)
        .set("resources", resources);

        if (!crossNavigations.empty)
            json = json.set("crossNavigation", crossNavigations);

        return json;
    }
}

struct CrossNavigation {
    Inbound[string] inbounds; /// The inbounds used for cross-navigation.

    Json toJson() const {
        auto jsonInbounds = Json.emptyObject;
        foreach(key, inbound; inbounds) {
            jsonInbounds[key] = inbound.toJson();
        }
        return Json.emptyObject.set("inbounds", jsonInbounds);
    }
}

struct Inbound {
    string semanticObject; /// The semantic object of the inbound.
    string action; /// The action of the inbound.
    string title; /// The title of the inbound.
    string description; /// The description of the inbound.
    string signature; /// The signature of the inbound.

    Json toJson() const {
        return Json.emptyObject
            .set("semanticObject", semanticObject)
            .set("action", action)
            .set("title", title)
            .set("description", description)
            .set("signature", signature);
    }
}   