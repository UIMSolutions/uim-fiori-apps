sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("projects.app.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // Rufen Sie die init-Funktion des Eltern-Elements auf
            UIComponent.prototype.init.apply(this, arguments);

            // Globales Detail-Model für die Kommunikation zwischen Master und Detail
            this.setModel(new JSONModel(), "detail");
        }
    });
});