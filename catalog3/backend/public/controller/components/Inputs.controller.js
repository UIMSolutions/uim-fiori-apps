sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Inputs", {
        
        onInit: function () {
            console.log("Inputs component view initialized successfully.");
        },

        onLiveChange: function (oEvent) {
            var sVal = oEvent.getParameter("value");
            this.byId("outputLabel").setText("Live Value: " + sVal);
        },

        onValueHelpRequest: function () {
            MessageToast.show("Value Help dialog requested!");
        }

    });
});