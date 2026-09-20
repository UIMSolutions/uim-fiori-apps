sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Wizards", {
        
        onInit: function () {
            console.log("Wizard component view initialized successfully.");
        },

        onInputChange: function (oEvent) {
            var sValue = oEvent.getParameter("value");
            if (sValue.trim().length > 0) {
                this.byId("wizardStatusLabel").setText("Status: Progressing with item name -> " + sValue);
            }
        },

        onWizardCompleted: function () {
            MessageToast.show("Wizard completed successfully!");
            this.byId("wizardStatusLabel").setText("Status: Workflow completed and submitted!");
        }

    });
});