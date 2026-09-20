sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Trees", {
        
        onInit: function () {
            var oData = {
                nodes: [
                    {
                        title: "SAPUI5 Libraries",
                        icon: "sap-icon://folder",
                        nodes: [
                            {
                                title: "sap.m (Main Controls)",
                                icon: "sap-icon://wrench",
                                nodes: [
                                    { title: "Button", icon: "sap-icon://detail-view" },
                                    { title: "Input", icon: "sap-icon://edit" },
                                    { title: "List", icon: "sap-icon://list" }
                                ]
                            },
                            {
                                title: "sap.suite.ui.microchart",
                                icon: "sap-icon://bar-chart",
                                nodes: [
                                    { title: "Area Micro Chart", icon: "sap-icon://line-chart" },
                                    { title: "Bullet Micro Chart", icon: "sap-icon://horizontal-bar-chart" },
                                    { title: "Line Micro Chart", icon: "sap-icon://chart-line" }
                                ]
                            }
                        ]
                    },
                    {
                        title: "Backend Services (Vibe.d)",
                        icon: "sap-icon://server",
                        nodes: [
                            { title: "app.d Provider", icon: "sap-icon://source-code" },
                            { title: "REST Router", icon: "sap-icon://globe" }
                        ]
                    }
                ]
            };

            var oModel = new JSONModel(oData);
            this.getView().setModel(oModel);
            console.log("Tree component view initialized successfully.");
        },

        onNodeSelected: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var oContext = oItem.getBindingContext();
            var sTitle = oContext.getProperty("title");
            
            MessageToast.show("Selected Node: " + sTitle);
            this.byId("treeStatusLabel").setText("Status: Selected node -> " + sTitle);
        }

    });
});