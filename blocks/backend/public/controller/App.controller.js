sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.App", {

        onToggleSideNav: function () {
            var oToolPage = this.byId("toolPage");
            oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
        },

        onSideNavSelect: function (oEvent) {
            var sKey = oEvent.getParameter("item").getKey();
            if (sKey) {
                MessageToast.show("Navigation zu: " + sKey);
            }
        },

        onLogout: function () {
            MessageToast.show("Erfolgreich abgemeldet.");
        }

    });
});