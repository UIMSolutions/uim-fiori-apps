sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.DatePickers", {
        
        onInit: function () {
            console.log("DatePicker component view initialized successfully.");
        },

        onDateChange: function (oEvent) {
            var sValue = oEvent.getParameter("value");
            var bValid = oEvent.getParameter("valid");
            
            if (bValid && sValue) {
                MessageToast.show("Selected Date: " + sValue);
                this.byId("dateStatusLabel").setText("Status: Successfully selected date -> " + sValue);
            } else {
                MessageToast.show("Invalid date entered.");
                this.byId("dateStatusLabel").setText("Status: Warning - Invalid date format entered.");
            }
        }

    });
});