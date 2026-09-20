sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Breadcrumbs", {
        
        onInit: function () {
            console.log("Breadcrumbs component view initialized successfully.");
        },

        onBreadcrumbClicked: function (oEvent) {
            var oItem = oEvent.getParameter("item");
            var sText = oItem ? oItem.getText() : "Unknown Link";
            
            MessageToast.show("Navigated to: " + sText);
            this.byId("breadcrumbsStatusLabel").setText("Status: Activated path node -> " + sText);
        }

    });
});