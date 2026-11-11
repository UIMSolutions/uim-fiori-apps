sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";

    return UIComponent.extend("ea.architecture.manager.Component", {

        metadata: {
            manifest: "json"
        },

        init: function () {
            // 1. ZUERST die init-Funktion der Basisklasse aufrufen!
            // Erst dadurch liest UI5 das manifest.json und instanziiert den Router.
            UIComponent.prototype.init.apply(this, arguments);

            // 2. JETZT ist this.getRouter() verfügbar und kann initialisiert werden.
            this.getRouter().initialize();
        }
    });
});