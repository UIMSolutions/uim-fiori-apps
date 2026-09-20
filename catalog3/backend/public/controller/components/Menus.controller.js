sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Menus", {
        
        onInit: function () {
            console.log("Menu component view initialized successfully.");
        },

        onMenuItemSelected: function (oEvent) {
            var oItem = oEvent.getParameter("item");
            var sKey = oItem.getKey();
            var sText = oItem.getText();
            
            MessageToast.show("Selected: " + sText);
            this.byId("menuStatusLabel").setText("Status: Selected menu item key = '" + sKey + "'");
        }

    });
});