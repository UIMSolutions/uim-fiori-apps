sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("ea.architecture.manager.Component", {

        metadata: {
            manifest: "json"
        },

        init: function () {
            // Rufe die init-Funktion der Basisklasse auf
            UIComponent.prototype.init.apply(this, arguments);

            // Initialisiere den Router basierend auf der Konfiguration im manifest.json
            this.getRouter().initialize();

            // Optional: Zentrales Model für das vibe.d Backend manuell binden, 
            // falls nicht bereits direkt im manifest.json unter sap.app.dataSources hinterlegt:
            /*
            var sBackendUrl = "http://localhost:8080/api/";
            var oVibeModel = new JSONModel(sBackendUrl + "buildingblocks");
            this.setModel(oVibeModel, "vibeApi");
            */
        }
    });
});