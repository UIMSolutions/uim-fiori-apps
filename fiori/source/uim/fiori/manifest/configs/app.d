module uim.fiori.manifest.configs.app;

import uim.fiori;

@safe:

struct SapAppConfig {
    string id; // Represents mandatory unique app identifier which must correspond to component 'id/namespace'
    string type; // Represents type of an application and can be application or component or library or card
    string i18n; /// The path to the i18n properties file.
    string applicationVersion; /// The version of the application.
    SourceTemplate sourceTemplate; /// The source template used to generate the application.
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
    string[] cdsViews; /// The CDS views used by the application.
    bool offline; /// Indicates whether the application supports offline mode.
    string[] openSourceComponents; /// The open source components used by the application.
    string provider; /// The provider of the application.
    CrossNavigation[string] crossNavigations; /// The cross-navigation configuration of the application.
    Resource[] resources; /// The resources used by the application.

    Json toJson() const {
        auto result = Json.emptyObject
            .set("id", id)
            .set("type", type)
            .set("title", title)
            .set("applicationVersion", Json.emptyObject.set("version", applicationVersion));

        return result;
    }
}

/// Represents cross navigation for inbound and outbound targets
struct CrossNavigation {
    // Scope[string] scopes; /// The scopes of the cross navigation.
    Inbound[string] inbounds; /// The inbounds used for cross-navigation.
    Outbound[string] outbounds; /// The outbounds used for cross-navigation.

    Json toJson() const {
        auto jsonInbounds = Json.emptyObject;
        foreach (key, inbound; inbounds) {
            jsonInbounds[key] = inbound.toJson();
        }

        auto result = Json.emptyObject
            .set("inbounds", jsonInbounds);

        // if (!scopes.empty) {
        //     auto jsonScopes = Json.emptyObject;
        //     foreach (key, s; scopes) {
        //         jsonScopes[key] = s.toJson();
        //     }
        //     result = result.set("scopes", jsonScopes);
        // }

        if (!outbounds.empty) {
            auto jsonOutbounds = Json.emptyObject;
            foreach (key, outbound; outbounds) {
                jsonOutbounds[key] = outbound.toJson();
            }
            result = result.set("outbounds", jsonOutbounds);
        }

        return result;
    }
}

struct Outbound {
    string semanticObject; /// The semantic object of the outbound.
    string action; /// The action of the outbound.
    string title; /// The title of the outbound.
    string description; /// The description of the outbound.

    Json toJson() const {
        auto json = Json.emptyObject
            .set("semanticObject", semanticObject)
            .set("action", action);

        if (!title.empty)
            json = json.set("title", title);
        if (!description.empty)
            json = json.set("description", description);

        return json;
    }

    static Outbound fromJson(Json json) {
        Outbound outbound = Outbound();
        outbound.semanticObject = json.getString("semanticObject");
        outbound.action = json.getString("action");
        outbound.title = json.getString("title");
        outbound.description = json.getString("description");
        return outbound;
    }
}

// struct Inbound {
    // string semanticObject; /// The semantic object of the inbound.
    // string action; /// The action of the inbound.
    // bool hideLauncher; /// Indicates to not expose this inbound as a tile or link.
    // string icon; /// The icon of the inbound.
    // string title; /// The title of the inbound.
    // string subTitle; /// The subtitle of the inbound.
    // string shortTitle; /// The shorter version of the title.
    // string info; /// Additional information to the title.
    // DisplayMode displayMode; /// The display mode of the inbound.
// }
// IndicatorDataSource indicatorDataSource; /// The indicator data source of the inbound.
//                         "indicatorDataSource": {
//                             "description": "Represents data source",
//                             "type": "object",
//                             "required": [
//                                 "dataSource",
//                                 "path"
//                             ],
//                         },
//                         "deviceTypes": {
//                             "description": "Represents device types for which application is developed",
//                             "$ref": "#/$defs/deviceType"
//                         },
//                         "signature": {
//                             "$ref": "#/$defs/signature_def"
//                         }
// }

// "scopes" :  {
//     "description" : "Represents scopes of a site",
//     "type" : "object",
//     "additionalProperties" : false,
//     "patternProperties" :  {
//         "^[a-zA-Z0-9_\\.\\-]+$" :  {
//             "description" : "Represents unique id of the site",
//             "type" : "object",
//             "required" : [
//                 "value"
//             ],
//             "properties" :  {
//                 "value" :  {
//                     "type" : "string"
//                 }
//             }
//         }
//     }
// },
// "inbounds" :  {
//     "description" : "Represents cross navigation for inbound target",
//     "$ref" : "#/$defs/inbound"
// },
// "outbounds" :  {
//     "description" : "Describes intents that can be triggered from the application to navigate",
//     "$ref" : "#/$defs/outbound"
// }
// }
// }
// }

struct Inbound {
    string semanticObject; /// The semantic object of the inbound.
    string action; /// The action of the inbound.
    string title; /// The title of the inbound.
    string description; /// The description of the inbound.
    string signature; /// The signature of the inbound.

    Json toJson() const {
        auto json = Json.emptyObject;
        if (!semanticObject.empty)
            json = json.set("semanticObject", semanticObject);
        if (!action.empty)
            json = json.set("action", action);
        if (!title.empty)
            json = json.set("title", title);
        if (!description.empty)
            json = json.set("description", description);
        if (!signature.empty)
            json = json.set("signature", signature);
        return json;
    }

    static Inbound fromJson(Json json) {
        Inbound inbound = Inbound();
        if (json.hasKey("semanticObject"))
            inbound.semanticObject = json.getString("semanticObject");
        if (json.hasKey("action"))
            inbound.action = json.getString("action");
        if (json.hasKey("title"))
            inbound.title = json.getString("title");
        if (json.hasKey("description"))
            inbound.description = json.getString("description");
        if (json.hasKey("signature"))
            inbound.signature = json.getString("signature");
        return inbound;
    }
}

struct SourceTemplate {
    string id; // Represents id of the template from which the app was generated 
    string version_; // Represents the version of the template from which the app was generated
    string toolsId; // Represents an Id generated by SAP Fiori tools

    Json toJson() const {
        auto result = Json.emptyObject
            .set("id", id)
            .set("version", version_);
        if (!toolsId.isEmpty)
            result["toolsId"] = toolsId;
        return result;
    }

    static SourceTemplate fromJson(Json data) {
        auto result = SourceTemplate();
        result.id = data.getString("id");
        result.version_ = data.getString("version");
        result.toolsId = data.getString("toolsId");
        return result;
    }
}

struct ApplicationVersion {
    string version_;

    Json toJson() const {
        return Json.emptyObject.set("version", version_);
    }

    static ApplicationVersion fromJson(Json data) {
        auto result = ApplicationVersion();
        result.version_ = data.getString("version");
        return result;
    }
}

struct Tags {
    string[] keywords;

    Json toJson() const {
        auto result = Json.emptyObject;
        if (!keywords.empty)
            result = result.set("keywords", keywords.toJson);
        return result;
    }

    static Tags fromJson(Json data) {
        auto result = Tags();
        if (data.hasKey("keywords")) {
            auto keywordsJson = data.getArray("keywords");
            result.keywords = null;
            for (int i = 0; i < keywordsJson.length; i++) {
                result.keywords[i] = keywordsJson.getString(i);
            }
        }
        return result;
    }
}
