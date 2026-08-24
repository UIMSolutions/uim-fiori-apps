sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";

    return UIComponent.extend("todo.app.Component", {
        metadata: {
            manifest: "json"
        },

        /**
         * Die init-Funktion wird beim Start der Komponente aufgerufen.
         */
        init: function () {
            // Aufruf der init-Funktion der Superklasse (lädt u.a. das manifest.json und erstellt Models)
            UIComponent.prototype.init.apply(this, arguments);
        }
    });
});