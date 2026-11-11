sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/f/library"
], function (Controller, fLibrary) {
    "use strict";

    var LayoutType = fLibrary.LayoutType;

    return Controller.extend("ea.architecture.manager.controller.ArchitectureMasterDetail", {

        onListItemPress: function (oEvent) {
            var oListItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oListItem.getBindingContext();

            if (!oContext) {
                console.error("Kein BindingContext vorhanden!");
                return;
            }

            var oFCL = this.byId("fcl");
            var oDetailPage = this.byId("detailPage");

            if (oDetailPage && oFCL) {
                // 1. Kontext zuweisen
                oDetailPage.setBindingContext(oContext);

                // 2. Daten laden abwarten und erst dann Layout erweitern
                oContext.requestObject().then(function () {
                    oFCL.setLayout(LayoutType.TwoColumnsMidExpanded);
                }).catch(function (oError) {
                    console.error("Fehler beim Laden der Detailsicht:", oError);
                });
            }
        },

        // Formatter für den ObjectStatus
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

        onDependencyPress: function (oEvent) {
            var oItem = oEvent.getSource();
            var oDependencyContext = oItem.getBindingContext();
            var sTargetId = oDependencyContext.getProperty("ID");

            if (!sTargetId) {
                return;
            }

            console.log("Wechsle im Detailbereich zu ID:", sTargetId);

            var oModel = this.getView().getModel();
            var oDetailPage = this.byId("detailPage");
            var oFCL = this.byId("fcl");
            var oMasterList = this.byId("masterList");

            // 1. OData v4 Key-Binding für den Ziel-Baustein erstellen
            var sPath = "/ArchitectureBlocks('" + sTargetId + "')";
            var oTargetContext = oModel.bindContext(sPath).getBoundContext();

            // 2. Kontext an die Detailseite binden
            oDetailPage.setBindingContext(oTargetContext);

            // 3. In der Master-Liste das entsprechende Item selektieren (falls vorhanden)
            if (oMasterList) {
                var aItems = oMasterList.getItems();
                aItems.forEach(function (oListItem) {
                    var oCtx = oListItem.getBindingContext();
                    if (oCtx && oCtx.getProperty("ID") === sTargetId) {
                        oMasterList.setSelectedItem(oListItem);
                    }
                });
            }

            // 4. Daten laden abwarten und FCL-Layout aufklappen
            oTargetContext.requestObject().then(function () {
                if (oFCL) {
                    oFCL.setLayout(sap.f.LayoutType.TwoColumnsMidExpanded);
                }
            }).catch(function (oError) {
                console.error("Fehler beim Laden des abhängigen Bausteins:", oError);
            });
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});