sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.AnalyticalTable", {
        
        onInit: function () {
            // Provide a localized mock dataset representing analytical dimensions & measures
            var oData = {
                salesData: [
                    { Region: "North America", Manager: "Alice Smith", Product: "Cloud License", Revenue: 45000, Quantity: 5 },
                    { Region: "North America", Manager: "Alice Smith", Product: "Support Pack", Revenue: 12000, Quantity: 12 },
                    { Region: "Europe", Manager: "Hans Gruber", Product: "Cloud License", Revenue: 38000, Quantity: 4 },
                    { Region: "Europe", Manager: "Hans Gruber", Product: "Consulting Hours", Revenue: 15000, Quantity: 20 },
                    { Region: "Asia Pacific", Manager: "Kenji Sato", Product: "Cloud License", Revenue: 52000, Quantity: 6 },
                    { Region: "Asia Pacific", Manager: "Kenji Sato", Product: "Support Pack", Revenue: 8500, Quantity: 8 }
                ]
            };

            var oModel = new JSONModel(oData);
            this.getView().setModel(oModel);
            console.log("AnalyticalTable component view initialized successfully.");
        },

        onSelectionAction: function () {
            var oTable = this.byId("analyticalTable");
            var aIndices = oTable.getSelectedIndices();
            
            if (aIndices.length > 0) {
                MessageToast.show(aIndices.length + " row(s) selected in AnalyticalTable.");
            } else {
                MessageToast.show("Please select at least one row in the table.");
            }
        }

    });
});