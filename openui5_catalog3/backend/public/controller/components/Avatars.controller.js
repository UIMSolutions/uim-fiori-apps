sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Avatars", {
        
        onInit: function () {
            console.log("Avatars component view initialized successfully.");
        },

        onAvatarPress: function (oEvent) {
            var sDetails = oEvent.getSource().getInitials() || oEvent.getSource().getSrc() || "Icon Avatar";
            MessageToast.show("Avatar clicked: " + sDetails);
            this.byId("avatarStatusLabel").setText("Status: Interacted with avatar (" + sDetails + ")");
        }

    });
});