sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
    "use strict";
    return Controller.extend("contact.manager.controller.Dashboard", {
        onTilePress: function () {
            this.getOwnerComponent().getRouter().navTo("MasterDetail");
        }
    });
});