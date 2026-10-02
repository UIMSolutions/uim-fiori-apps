sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/routing/History"
], function (Controller, History) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.ArchitectureBlocks", {

        onViewChange: function (oEvent) {
            var sSelectedKey = oEvent.getParameter("item").getKey();
            
            var oCardsView = this.byId("cardsView");
            var oTableView = this.byId("tableView");

            if (sSelectedKey === "cards") {
                oCardsView.setVisible(true);
                oTableView.setVisible(false);
            } else if (sSelectedKey === "table") {
                oCardsView.setVisible(false);
                oTableView.setVisible(true);
            }
        },

        onNavBack: function () {
            var oHistory = History.getInstance();
            var sPreviousHash = oHistory.getPreviousHash();

            if (sPreviousHash !== undefined) {
                window.history.go(-1);
            } else {
                var oRouter = this.getOwnerComponent().getRouter();
                oRouter.navTo("Home", {}, true);
            }
        }
    });
});