sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";
    return Controller.extend("my.app.namespace.controller.Master", {
        onInit: function () {
            // Load the catalog from Vibe.d
            var oModel = new JSONModel("/api/components");
            this.getView().setModel(oModel);
        },
        
        onSelect: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var sComponentId = oItem.getBindingContext().getProperty("id");
            
            this.getOwnerComponent().getRouter().navTo("detail", {
                componentId: sComponentId
            });
        }
    });
});