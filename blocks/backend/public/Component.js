sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";

    return UIComponent.extend("ea.architecture.manager.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // Base Component Initialization
            UIComponent.prototype.init.apply(this, arguments);

            // Router erst initialisieren, wenn er existiert
            var oRouter = this.getRouter();
            if (oRouter) {
                oRouter.initialize();
            } else {
                console.error("Router konnte nicht instanziiert werden. Bitte 'sap.ui5.routing' in manifest.json prüfen.");
            }
        }
    });
});