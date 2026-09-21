sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.ArchitectureMasterDetail", {
        onInit: function () {
            // var oRouter = this.getOwnerComponent().getRouter();
            // oRouter.getRoute("architecture").attachPatternMatched(this._onRouteMatched, this);
            
            // this.getView().setModel(new JSONModel({}), "detailModel");

            // Leeres Modell für die Detail-Ansicht initialisieren
            var oDetailModel = new JSONModel({});
            this.getView().setModel(oDetailModel, "detailModel");
        },

        _onRouteMatched: function () {
            // Lade nur Architekturbausteine vom vibe.d Backend
            var oMasterModel = new JSONModel("http://localhost:8080/api/buildingblocks?type=Architecture");
            this.getView().setModel(oMasterModel, "architectureModel");
        },

        onListItemPress: function (oEvent) {
            // var oSelectedItem = oEvent.getSource();
            // var oContext = oSelectedItem.getBindingContext("architectureModel");
            
            // var oFCL = this.byId("fcl");
            // oFCL.setLayout(sap.f.LayoutType.TwoColumnsExpanded);

            // this.getView().getModel("detailModel").setData(oContext.getObject());

            // 1. Das angeklickte Item und dessen Daten-Kontext ermitteln
            var oSelectedItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oSelectedItem.getBindingContext("vibeApi");
            
            if (oContext) {
                // 2. Daten des gewählten Bausteins holen
                var oSelectedData = oContext.getObject();

                // 3. Daten in das detailModel schreiben
                this.getView().getModel("detailModel").setData(oSelectedData);

                // 4. Layout auf 2 Spalten erweitern (Master + Detail)
                var oFCL = this.byId("fcl");
                oFCL.setLayout("TwoColumnsExpanded");
            }
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});