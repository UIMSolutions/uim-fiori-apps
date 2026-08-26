sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("projects.app.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // Rufen Sie die init-Funktion des Eltern-Elements auf
            UIComponent.prototype.init.apply(this, arguments);
        }
    });
});