sap.ui.define([
    "sap/ui/core/UIComponent"
], function (UIComponent) {
    "use strict";
    return UIComponent.extend("hello.fiori.vibe.Component", {
        metadata: {
            manifest: "json"
        },
        init: function () {
            // Rufen Sie die init-Funktion der Mutterklasse auf
            UIComponent.prototype.init.apply(this, arguments);
        }
    });
});