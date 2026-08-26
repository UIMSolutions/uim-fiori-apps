sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";

    return UIComponent.extend("projects.app.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // 1. Basis-init aufrufen (erstellt die rootView aus der manifest.json)
            UIComponent.prototype.init.apply(this, arguments);

            // 2. Warten, bis das Root-Control (App.view.xml) geladen ist
            this.getRootControl().loaded().then(function (oRootView) {
                // 3. Erst wenn die View geladen ist, den Router starten
                this.getRouter().initialize();
            }.bind(this));
        }
    });
});