sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Home", {
        
        onNavToBlocks: function () {
            this.getOwnerComponent().getRouter().navTo("ArchitectureBlocks");
        },

        onNavToCards: function () {
            this.getOwnerComponent().getRouter().navTo("CardsOverview");
        },

        onNavToSettings: function () {
            this.getOwnerComponent().getRouter().navTo("Settings");
        },

        onCardAction: function (oEvent) {
            var sActionType = oEvent.getParameter("type");
            var oParameters = oEvent.getParameter("parameters");

            if (sActionType === "Navigation") {
                // Falls Parameter in der Card definiert sind, z. B. target: "Settings"
                if (oParameters && oParameters.target) {
                    this.getOwnerComponent().getRouter().navTo(oParameters.target);
                } else {
                    this.getOwnerComponent().getRouter().navTo("ArchitectureBlocks");
                }
            }
        }
    });
});