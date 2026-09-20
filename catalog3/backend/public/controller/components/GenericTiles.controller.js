sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.GenericTiles", {
        
        onInit: function () {
            console.log("GenericTile component view initialized successfully.");
        },

        onTilePress: function (oEvent) {
            var sHeader = oEvent.getSource().getHeader();
            MessageToast.show("Tile pressed: " + sHeader);
            this.byId("tileStatusLabel").setText("Status: Interacted with tile '" + sHeader + "'");
        }

    });
});