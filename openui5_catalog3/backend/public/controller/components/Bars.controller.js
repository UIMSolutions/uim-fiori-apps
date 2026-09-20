sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Bars", {
        
        onInit: function () {
            console.log("Bars component view initialized successfully.");
        },

        onBarAction: function (oEvent) {
            var sSource = oEvent.getSource().getText() || oEvent.getSource().getIcon();
            MessageToast.show("Action triggered from: " + sSource);
            this.byId("barStatusLabel").setText("Bar Status: Triggered action on " + sSource);
        },

        onBarLiveChange: function (oEvent) {
            var sQuery = oEvent.getParameter("value");
            this.byId("barStatusLabel").setText("Bar Status: Filtering by '" + sQuery + "'");
        }

    });
});