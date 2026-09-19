sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("my.app.controller.Master", {
        onInit: function () {
            var oModel = new JSONModel("/api/components");
            this.getView().setModel(oModel);
        },
        
        onSelect: function (oEvent) {
            var sComponentId = oEvent.getParameter("listItem").getBindingContext().getProperty("id");
            
            this.getOwnerComponent().getRouter().navTo("detail", {
                componentId: sComponentId,
                layout: "TwoColumnsMidExpanded"
            });
        }
    });
});