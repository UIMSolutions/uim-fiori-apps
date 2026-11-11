sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Home", {
        
        onScrollToGroup: function (sGroupId) {
            var oTarget = this.byId(sGroupId);
            if (oTarget && oTarget.getDomRef()) {
                oTarget.getDomRef().scrollIntoView({
                    behavior: "smooth",
                    block: "start"
                });
            }
        },

        onNavigateTo: function (sCategory, sAction) {
            var oRouter = this.getOwnerComponent().getRouter();
            // Bspw. Navigation zu Route "manageBuildingBlocks" mit Parametern
            oRouter.navTo(sCategory+"_"+sAction);
        }
    });
});