sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.NewsContents", {
        
        onInit: function () {
            console.log("NewsContent component view initialized successfully.");
        },

        onTilePress: function (oEvent) {
            var sHeader = oEvent.getSource().getHeader();
            MessageToast.show("News tile pressed: " + sHeader);
            this.byId("newsStatusLabel").setText("Status: Interacted with news tile '" + sHeader + "'");
        }

    });
});