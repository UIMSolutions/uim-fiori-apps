sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.SlideTiles", {
        
        onInit: function () {
            console.log("SlideTile component view initialized successfully.");
        },

        onTilePress: function (oEvent) {
            var sHeader = oEvent.getSource().getHeader();
            MessageToast.show("SlideTile pressed: " + sHeader);
            this.byId("slideTileStatusLabel").setText("Status: Interacted with active slide tile '" + sHeader + "'");
        }

    });
});