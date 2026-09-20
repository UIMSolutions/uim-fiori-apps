sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Graph", {
        
        onInit: function () {
            var oData = {
                nodes: [
                    { key: "root", title: "Vibe.D Backend", icon: "sap-icon://server" },
                    { key: "service", title: "API Router", icon: "sap-icon://journey-arrive" },
                    { key: "ui5", title: "UI5 Fiori App", icon: "sap-icon://desktop-mobile" },
                    { key: "fcl", title: "FlexibleColumnLayout", icon: "sap-icon://largetable" }
                ],
                lines: [
                    { from: "root", to: "service" },
                    { from: "service", to: "ui5" },
                    { from: "ui5", to: "fcl" }
                ]
            };

            var oModel = new JSONModel(oData);
            this.getView().setModel(oModel);
        },

        onHighlightNode: function () {
            var oGraph = this.byId("networkGraph");
            var oNode = oGraph.getNodeByKey("root");
            if (oNode) {
                oNode.setSelected(true);
                MessageToast.show("Highlighted: " + oNode.getTitle());
            }
        }

    });
});