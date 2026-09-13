module uim.fiori.landscape.presentation.ui5.manifest;
public:
    import uim.fiori.landscape;
void manifestHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto manifestConfig = ManifestConfig();
    // Handle the manifest request using the manifestConfig
    manifestConfig.appId              = "landscape.frontend";
    manifestConfig.appTitle           = "Application";
    manifestConfig.appDescription     = "An SAP UI5 application";
    manifestConfig.appVersion         = "1.0.0";
    manifestConfig.minUI5Version      = "1.120.0";
    manifestConfig.rootViewName       = ""; // wird ggf. aus appId abgeleitet
    manifestConfig.rootViewType       = "XML";
    manifestConfig.rootViewId         = "app";
    manifestConfig.icon               = "sap-icon://Fiori2/F0002";
    manifestConfig.favIcon            = "";
    manifestConfig.themeName          = "sap_horizon";
    manifestConfig.outputPath         = "manifest.json";
    manifestConfig.flexibleColumnLayout = "";
    manifestConfig.withRouting          = false;
    manifestConfig.withOData            = false;
    manifestConfig.odataUri           = "/sap/opu/odata/sap/YOUR_SRV/";
    manifestConfig.odataModelName     = "";
    manifestConfig.extraLibs        = [];
    manifestConfig.phoneSupport         = true;
    manifestConfig.tabletSupport        = true;
    manifestConfig.desktopSupport       = true;
    manifestConfig.prettyPrint          = true;
    manifestConfig.writeI18n            = true;
    manifestConfig.interactive          = false;
}