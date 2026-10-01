sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("launchpad.frontend.controller.App", {
        onItemSelect: function (oEvent) {
            var sKey = oEvent.getParameter("item").getKey();
            this.getOwnerComponent().getRouter().navTo(sKey);
        }
    });
});
