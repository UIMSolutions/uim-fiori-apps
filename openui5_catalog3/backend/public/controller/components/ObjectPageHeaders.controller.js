sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.ObjectPageHeaders", {
        
        onInit: function () {
            console.log("ObjectPageHeader component view initialized successfully.");
        },

        onFavoritePress: function (oEvent) {
            var bState = oEvent.getParameter("state");
            MessageToast.show("Favorite status toggled: " + bState);
            this.byId("headerStatusLabel").setText("Status: Favorite marker set to " + bState);
        },

        onFlagPress: function (oEvent) {
            var bState = oEvent.getParameter("state");
            MessageToast.show("Flag status toggled: " + bState);
            this.byId("headerStatusLabel").setText("Status: Flag marker set to " + bState);
        },

        onActionPress: function (oEvent) {
            var sText = oEvent.getSource().getText() || oEvent.getSource().getIcon();
            MessageToast.show("Action triggered: " + sText);
            this.byId("headerStatusLabel").setText("Status: Triggered action element '" + sText + "'");
        }

    });
});