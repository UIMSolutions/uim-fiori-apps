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
            
            // Format ID for Title & View matching (e.g., "buttons" -> "Buttons")
            var sTitle = sComponentId.charAt(0).toUpperCase() + sComponentId.slice(1);
            oPage.setTitle(sTitle + " Component Test");
            
            // Destroy previous content to free up duplicate UI5 control IDs
            oPage.destroyContent();

            XMLView.create({
                viewName: "my.app.view.components." + sTitle
            }).then(function (oView) {
                oPage.addContent(oView);
            }).catch(function(err) {
                console.error("View not found: " + sTitle);
            });
        },

        onClose: function () {
            // Revert layout back to Master list only
            this.getOwnerComponent().getRouter().navTo("master");
        }
    });
});