sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("projects.app.controller.Detail", {
        onInit: function () {
            // Bindet das globale "detail"-Model an diese View
            var oDetailModel = this.getOwnerComponent().getModel("detail");
            this.getView().setModel(oDetailModel, "project");
        }
    });
});