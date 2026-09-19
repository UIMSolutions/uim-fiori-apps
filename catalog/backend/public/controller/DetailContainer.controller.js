sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView"
], function (Controller, XMLView) {
    "use strict";
    return Controller.extend("my.app.namespace.controller.DetailContainer", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("detail").attachPatternMatched(this._onComponentMatched, this);
        },

        _onComponentMatched: function (oEvent) {
            var sComponentId = oEvent.getParameter("arguments").componentId;
            var oPage = this.byId("dynamicPage");
            
            // Clean up previous view
            oPage.destroyContent();

            // Capitalize the ID (e.g., "buttons" -> "Buttons")
            var sViewName = sComponentId.charAt(0).toUpperCase() + sComponentId.slice(1);

            // Dynamically load the separate XML view (e.g., "my.app.namespace.view.components.Buttons")
            XMLView.create({
                viewName: "my.app.namespace.view.components." + sViewName
            }).then(function (oView) {
                oPage.addContent(oView);
            });
        }
    });
});