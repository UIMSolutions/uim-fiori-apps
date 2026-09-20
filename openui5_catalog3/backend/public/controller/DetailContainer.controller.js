sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("my.app.controller.DetailContainer", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("detail").attachPatternMatched(this._onRouteMatched, this);
            oRouter.getRoute("subDetail").attachPatternMatched(this._onRouteMatched, this);
        },

        _onRouteMatched: function (oEvent) {
            var sNamespaceId = oEvent.getParameter("arguments").namespaceId;
            var oView = this.getView();
            var oModel = oView.getModel();

            // If model isn't loaded yet, wait for it or fetch it
            if (!oModel) {
                oModel = new JSONModel("/api/components");
                oView.setModel(oModel);
            }

            // Wait for data to load if it's asynchronous
            oModel.dataLoaded().then(function() {
                var aNamespaces = oModel.getData();
                // Find the exact namespace object matching the URL parameter
                var oSelectedNamespace = aNamespaces.find(function (item) {
                    return item.id === sNamespaceId;
                });

                if (oSelectedNamespace) {
                    // Set title and bind the component list context properly
                    oView.byId("namespacePage").setTitle(oSelectedNamespace.name);
                    
                    // Create a dedicated local model for this namespace's components
                    var oLocalModel = new JSONModel(oSelectedNamespace);
                    oView.setModel(oLocalModel, "nsData");
                    
                    // Bind the list to the components array inside this namespace
                    var oList = oView.byId("componentList");
                    oList.setModel(oLocalModel);
                    oList.bindAggregation("items", {
                        path: "nsData>/components",
                        template: new sap.m.StandardListItem({
                            title: "{nsData>title}",
                            description: "{nsData>description}",
                            type: "Navigation"
                        })
                    });
                }
            });
        },

        onSelectComponent: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var sComponentId = oItem.getBindingContext("nsData").getProperty("id");
            var aHashParts = this.getOwnerComponent().getRouter().getHashChanger().getHash().split("/");
            var sNamespaceId = aHashParts[1];

            this.getOwnerComponent().getRouter().navTo("subDetail", {
                namespaceId: sNamespaceId,
                componentId: sComponentId,
                layout: "ThreeColumnsEndExpanded"
            });
        },

        onNavBack: function () {
            this.getOwnerComponent().getRouter().navTo("master", {
                layout: "OneColumn"
            });
        }
    });
});