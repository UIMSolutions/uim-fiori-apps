sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView"
], function (Controller, XMLView) {
    "use strict";

    return Controller.extend("my.app.controller.SubDetail", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("subDetail").attachPatternMatched(this._onComponentMatched, this);
        },

        _onComponentMatched: function (oEvent) {
            var sComponentId = oEvent.getParameter("arguments").componentId;
            var oPage = this.byId("componentDisplayPage");
            
            var sViewName = sComponentId.charAt(0).toUpperCase() + sComponentId.slice(1);
            oPage.setTitle(sViewName + " Component Testbed");
            oPage.destroyContent();

            var oOwnerComponent = this.getOwnerComponent();

            // Safely create and inject the component test view into Column 3
            oOwnerComponent.runAsOwner(function () {
                XMLView.create({
                    viewName: "my.app.view.components." + sViewName
                }).then(function (oView) {
                    oPage.addContent(oView);
                }).catch(function(err) {
                    console.error("Component display view not found: " + sViewName, err);
                });
            });
        },

        onCloseSubDetail: function () {
            var aHashParts = this.getOwnerComponent().getRouter().getHashChanger().getHash().split("/");
            
            // Go back to 2 columns, keeping the namespace selected
            this.getOwnerComponent().getRouter().navTo("detail", {
                namespaceId: aHashParts[1],
                layout: "TwoColumnsMidExpanded"
            });
        }
    });
});