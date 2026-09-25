sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/f/library",
    "sap/m/MessageToast"
], function (Controller, fLibrary, MessageToast) {
    "use strict";

    var LayoutType = fLibrary.LayoutType;

    return Controller.extend("uim.fiori_blocks.controller.BaseMasterDetail", {

        onListItemPress: function (oEvent) {
            var oListItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oListItem.getBindingContext();

            if (!oContext) return;

            var oFCL = this.byId("fcl");
            var oDetailPage = this.byId("detailPage");

            if (oDetailPage && oFCL) {
                oDetailPage.setBindingContext(oContext);

                oContext.requestObject().then(function () {
                    oFCL.setLayout(LayoutType.TwoColumnsExpanded);
                }).catch(function (oError) {
                    console.error("Fehler beim Laden des BaseBlocks:", oError);
                });
            }
        },

        onDependencyPress: function (oEvent) {
            var oItem = oEvent.getSource();
            var oDependencyContext = oItem.getBindingContext();
            var sTargetId = oDependencyContext.getProperty("ID");

            if (!sTargetId) return;

            var oModel = this.getView().getModel();
            var oDetailPage = this.byId("detailPage");
            var oFCL = this.byId("fcl");
            var oMasterList = this.byId("masterList");

            // Key-Binding für die OData v4 Einzel-Abfrage
            var sPath = "/BaseBlocks('" + sTargetId + "')";
            var oTargetContext = oModel.bindContext(sPath).getBoundContext();

            oDetailPage.setBindingContext(oTargetContext);

            // Selektion in der Master-Liste spiegeln
            if (oMasterList) {
                var aItems = oMasterList.getItems();
                aItems.forEach(function (oListItem) {
                    var oCtx = oListItem.getBindingContext();
                    if (oCtx && oCtx.getProperty("ID") === sTargetId) {
                        oMasterList.setSelectedItem(oListItem);
                    }
                });
            }

            oTargetContext.requestObject().then(function () {
                if (oFCL) {
                    oFCL.setLayout(LayoutType.TwoColumnsExpanded);
                }
                MessageToast.show("Gewechselt zu: " + sTargetId);
            }).catch(function (oError) {
                console.error("Fehler beim Laden der Abhängigkeit:", oError);
            });
        },

        formatCriticalityState: function (sCriticality) {
            switch (sCriticality) {
                case "High":
                    return "Error";
                case "Medium":
                    return "Warning";
                case "Low":
                    return "Success";
                default:
                    return "None";
            }
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});