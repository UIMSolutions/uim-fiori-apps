sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Grids", {
        
        onInit: function () {
            console.log("Grids component view initialized successfully.");
        },

        onGridAction: function () {
            MessageToast.show("Grid layout action triggered successfully!");
        }

    });
});