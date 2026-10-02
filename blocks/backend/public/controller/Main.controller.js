sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Main", {

        onInit: function () {
            // Controller-Initialisierung
        },

        onRefresh: function () {
            var oTable = this.byId("idArchitectureBlocksTable");
            var oBinding = oTable.getBinding("items");
            if (oBinding) {
                oBinding.refresh();
                MessageToast.show("Daten aktualisiert.");
            }
        },

        onNavToCards: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.navTo("CardsOverview");
        }

    });
});