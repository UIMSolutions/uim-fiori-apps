sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.Avatar", {
        onAvatarPress: function (oEvent) {
            var oAvatar = oEvent.getSource();
            var sInfo = oAvatar.getInitials() || oAvatar.getSrc() || oAvatar.getIcon() || "Avatar";
            var sMsg = "Clicked avatar: " + sInfo;
            
            var oLabel = this.byId("avatarStatusLabel");
            if (oLabel) {
                oLabel.setText("Status: " + sMsg);
            }

            MessageToast.show(sMsg);
        }
    });
});