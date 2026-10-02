module uim.fiori.manifest.configs.enumerations.app;

import uim.fiori;

@safe:

enum AppType {
    application,
    component,
    library,
    card
}

string toString(AppType appType) {
    switch (appType) {
        case AppType.application: return "application";
        case AppType.component: return "component";
        case AppType.library: return "library";
        case AppType.card: return "card";
        default: return "";
    }
}

AppType toAppType(string appType) {
    switch(appType) {
        case "application": return AppType.application;
        case "component": return AppType.component;
        case "library": return AppType.library;
        case "card": return AppType.card;
        default: return AppType.application; // or handle error appropriately
    }
}

enum DisplayMode {
    ContentMode,
    HeaderMode
}

string toString(DisplayMode displayMode) {
    switch (displayMode) {
        case DisplayMode.ContentMode: return "ContentMode";
        case DisplayMode.HeaderMode: return "HeaderMode";
        default: return "ContentMode"; // or handle error appropriately 
    }
}

DisplayMode toDisplayMode(string displayMode) {
    switch(displayMode) {
        case "ContentMode": return DisplayMode.ContentMode;
        case "HeaderMode": return DisplayMode.HeaderMode;
        default: return DisplayMode.ContentMode; // or handle error appropriately
    }
}

struct IndicatorDataSource {
    string dataSource; /// The data source of the indicator.
    string path; /// The path within the data source.
    int refresh; /// The refresh interval for the indicator.

    Json toJson() const {
        auto result = Json.emptyObject
            .set("dataSource", dataSource)
            .set("path", path);

        if (refresh > 0)
            result = result.set("refresh", refresh);

        return result;
    }

    // static IndicatorDataSource fromJson(Json json) {
        // IndicatorDataSource indicatorDataSource = IndicatorDataSource();
        // indicatorDataSource.dataSource = json.getString("dataSource");
        // indicatorDataSource.path = json.getString("path");
        // indicatorDataSource.refresh = json.getInteger("refresh");
        // return indicatorDataSource;
    // }
}

/// Represents type of the data source. 
enum DataSourceType {
    OData,
    ODataAnnotation,
    INA,
    XML,
    JSON,
    FHIR,
    WebSocket,
    http
}

string toString(DataSourceType dataSourceType) {
    switch (dataSourceType) {
        case DataSourceType.OData: return "OData";
        case DataSourceType.ODataAnnotation: return "ODataAnnotation";
        case DataSourceType.INA: return "INA";
        case DataSourceType.XML: return "XML";
        case DataSourceType.JSON: return "JSON";
        case DataSourceType.FHIR: return "FHIR";
        case DataSourceType.WebSocket: return "WebSocket";
        case DataSourceType.http: return "http";
        default: return "OData"; // or handle error appropriately
    }
}

DataSourceType toDataSourceType(string dataSourceType) {
    switch (dataSourceType) {
        case "OData": return DataSourceType.OData;
        case "ODataAnnotation": return DataSourceType.ODataAnnotation;
        case "INA": return DataSourceType.INA;
        case "XML": return DataSourceType.XML;
        case "JSON": return DataSourceType.JSON;
        case "FHIR": return DataSourceType.FHIR;
        case "WebSocket": return DataSourceType.WebSocket;
        case "http": return DataSourceType.http;
        default: return DataSourceType.OData; // or handle error appropriately
    }
}

enum BundleUrlRelativeTo {
    component,
    manifest
}

// string toString(BundleUrlRelativeTo value) {

// }