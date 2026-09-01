sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";

    return UIComponent.extend("sap.fiori.addressmanager.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // Aufruf der init-Funktion der Mutterklasse
            UIComponent.prototype.init.apply(this, arguments);

            // Router initialisieren (startet die Navigation gemäß manifest.json)
            this.getRouter().initialize();
        }
    });
});