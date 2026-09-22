sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Home", {
        onNavigateTo: function (sRouteName) {
            console.log("Navigating to route:", sRouteName);
            
            var oRouter = this.getOwnerComponent().getRouter();
            if (oRouter) {
                oRouter.navTo(sRouteName);
            } else {
                console.error("Router konnte nicht ermittelt werden!");
            }
        }
    });
});