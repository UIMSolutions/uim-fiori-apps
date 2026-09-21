sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Home", {
        onNavigateTo: function (sRouteName) {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.navTo(sRouteName);
        }
    });
});