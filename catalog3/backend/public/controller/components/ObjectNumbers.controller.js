sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.ObjectNumbers", {
        
        onInit: function () {
            console.log("ObjectNumber component view initialized successfully.");
        }

    });
});