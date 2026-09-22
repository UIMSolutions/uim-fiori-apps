sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/f/library"
], function (Controller, JSONModel, fLibrary) {
    "use strict";

    // 3. LayoutType aus der Library extrahieren
    var LayoutType = fLibrary.LayoutType;

    return Controller.extend("ea.architecture.manager.controller.ArchitectureMasterDetail", {
        onInit: function () {
            // 1. Daten direkt vom vibe.d Backend holen (inkl. Filter für Architekturbausteine)
            var sUrl = "http://localhost:8080/api/buildingblocks?type=Architecture";
            var oMasterModel = new JSONModel();
            
            oMasterModel.loadData(sUrl).then(function () {
                console.log("Daten erfolgreich von vibe.d geladen:", oMasterModel.getData());
            }).catch(function (oError) {
                console.error("Fehler beim Laden der Daten von vibe.d:", oError);
            });

            // Model an die View binden
            this.getView().setModel(oMasterModel, "masterData");

            // 2. Leeres Detail-Model initialisieren
            var oDetailModel = new JSONModel({});
            this.getView().setModel(oDetailModel, "detailData");
        },

        onListItemPress: function (oEvent) {
            // Ausgewähltes Element ermitteln
            var oItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oItem.getBindingContext("masterData");

            if (oContext) {
                var oSelectedObject = oContext.getObject();

                // Daten in das Detail-Model schreiben
                this.getView().getModel("detailData").setData(oSelectedObject);

                // Layout auf 2 Spalten erweitern
                var oFCL = this.byId("fcl");
                oFCL.setLayout(LayoutType.TwoColumnsExpanded);
            }
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});