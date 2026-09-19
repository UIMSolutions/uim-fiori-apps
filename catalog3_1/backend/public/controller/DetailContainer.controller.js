sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView"
], function (Controller, XMLView) {
    "use strict";

    return Controller.extend("my.app.controller.DetailContainer", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("detail").attachPatternMatched(this._onComponentMatched, this);
        },
        
        _onComponentMatched: function (oEvent) {
            var sComponentId = oEvent.getParameter("arguments").componentId;
            var oPage = this.byId("dynamicPage");
            
            var sTitle = sComponentId.charAt(0).toUpperCase() + sComponentId.slice(1);
            oPage.setTitle(sTitle + " Component Test");
            oPage.destroyContent();

            // 1. Get the owner component of the DetailContainer
            var oOwnerComponent = this.getOwnerComponent();

            // 2. Wrap the dynamic view creation inside runAsOwner
            oOwnerComponent.runAsOwner(function () {
                XMLView.create({
                    viewName: "my.app.view.components." + sTitle
                }).then(function (oView) {
                    oPage.addContent(oView);
                }).catch(function(err) {
                    console.error("View not found: " + sTitle);
                });
            });
        },

        onClose: function () {
            // Revert layout back to Master list only
            this.getOwnerComponent().getRouter().navTo("master");
        },

        onNavigateToSubDetail: function (oEvent) {
            // Assuming you clicked a specific item in the detail view
            var sComponentId = this.getView().getBindingContext().getProperty("id"); 
            var sSubItemId = "example-item-1"; // Get this dynamically based on what was clicked

            this.getOwnerComponent().getRouter().navTo("subDetail", {
                componentId: sComponentId,
                subItemId: sSubItemId,
                layout: "ThreeColumnsEndExpanded" // Expands the 3rd column
            });
        }

    });
});