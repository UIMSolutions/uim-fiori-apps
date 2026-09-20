sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Buttons", {
        
        onInit: function () {
            // Component-level initialization logic can go here
            console.log("Buttons component view initialized successfully.");
        },

        onButtonPress: function (oEvent) {
            var sButtonText = oEvent.getSource().getText();
            
            // Show a quick toast notification
            MessageToast.show("Clicked: " + sButtonText);
            
            // Update the status label dynamically
            this.byId("feedbackLabel").setText("Status: Last clicked '" + sButtonText + "'");
        }

    });
});