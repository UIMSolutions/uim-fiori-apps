sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.FeedContents", {
        
        onInit: function () {
            console.log("FeedContent component view initialized successfully.");
        },

        onTilePress: function (oEvent) {
            var sHeader = oEvent.getSource().getHeader();
            MessageToast.show("Feed Content tile pressed: " + sHeader);
            this.byId("feedStatusLabel").setText("Status: Interacted with feed tile '" + sHeader + "'");
        }

    });
});