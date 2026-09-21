sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.SolutionMasterDetail", {
        onInit: function () {
            var oDetailModel = new JSONModel({});
            this.getView().setModel(oDetailModel, "detailModel");
        },

        onListItemPress: function (oEvent) {
            var oSelectedItem = oEvent.getSource();
            var oContext = oSelectedItem.getBindingContext("vibeApi");
            
            // Layout auf TwoColumnsExpanded erweitern
            var oFCL = this.byId("fcl");
            oFCL.setLayout(sap.f.LayoutType.TwoColumnsExpanded);

            // Ausgewähltes Element an Detailansicht binden
            this.getView().getModel("detailModel").setData(oContext.getObject());
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});