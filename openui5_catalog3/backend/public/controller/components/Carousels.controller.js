sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Carousels", {
        
        onInit: function () {
            console.log("Carousel component view initialized successfully.");
        },

        onPageChanged: function (oEvent) {
            var sNewPageId = oEvent.getParameter("newActivePageId");
            MessageToast.show("Carousel page changed!");
            this.byId("carouselStatusLabel").setText("Status: Active page index updated");
        }

    });
});