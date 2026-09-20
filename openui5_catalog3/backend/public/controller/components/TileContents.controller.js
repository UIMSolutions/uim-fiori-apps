sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.TileContents", {
        
        onInit: function () {
            console.log("TileContent component view initialized successfully.");
        },

        onTilePress: function (oEvent) {
            var sHeader = oEvent.getSource().getHeader();
            MessageToast.show("TileContent container pressed: " + sHeader);
            this.byId("tileContentStatusLabel").setText("Status: Interacted with tile container '" + sHeader + "'");
        }

    });
});