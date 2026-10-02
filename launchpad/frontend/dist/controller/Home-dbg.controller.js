sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("launchpad.frontend.controller.Home", {
        onProductsPress: function () {
            this.getOwnerComponent().getRouter().navTo("products");
        },

        onReportsPress: function () {
            this.getOwnerComponent().getRouter().navTo("reports");
        },

        onSettingsPress: function () {
            this.getOwnerComponent().getRouter().navTo("settings");
        }
    });
});
