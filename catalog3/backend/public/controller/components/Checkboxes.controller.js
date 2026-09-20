sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Checkbox", {
        
        onInit: function () {
            console.log("Checkbox component view initialized successfully.");
        },

        onCheckBoxSelect: function (oEvent) {
            var bSelected = oEvent.getParameter("selected");
            var sText = oEvent.getSource().getText();
            
            MessageToast.show("'" + sText + "' is now " + (bSelected ? "Checked" : "Unchecked"));
            this.byId("checkboxStatusLabel").setText("Status: '" + sText + "' set to " + bSelected);
        }

    });
});