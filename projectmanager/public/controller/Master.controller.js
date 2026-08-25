sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("projects.app.controller.Master", {
        onInit: function () {
            var oModel = new JSONModel();
            oModel.loadData("/api/projects");
            this.getView().setModel(oModel, "projects");
        },

        onSelect: function (oEvent) {
            var oItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var sPath = oItem.getBindingContext("projects").getPath();
            var oSelectedProject = this.getView().getModel("projects").getProperty(sPath);

            this.getOwnerComponent().getModel("detail").setData(oSelectedProject);
        }
    });
});