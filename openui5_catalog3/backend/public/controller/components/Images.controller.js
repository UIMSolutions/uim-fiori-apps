sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Images", {
        
        onInit: function () {
            console.log("Image component view initialized successfully.");
        },

        onImagePress: function (oEvent) {
            var sSrc = oEvent.getSource().getSrc();
            MessageToast.show("Image clicked!");
            this.byId("imageStatusLabel").setText("Status: Interacted with image source -> " + sSrc);
        }

    });
});