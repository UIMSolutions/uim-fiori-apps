sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";
    return Controller.extend("taskmanager.fiori.controller.Detail", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("detail").attachPatternMatched(this._onObjectMatched, this);
        },
        _onObjectMatched: function (oEvent) {
            var sTaskId = oEvent.getParameter("arguments").taskId;
            var oDetailModel = new JSONModel();
            oDetailModel.loadData("/api/v1/tasks/" + sTaskId);
            this.getView().setModel(oDetailModel, "detail");
        },
        onSave: function () {
            var oModel = this.getView().getModel("detail");
            var oData = oModel.getData();
            fetch("/api/v1/tasks/" + oData.id, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(oData)
            }).then(function () {
                MessageToast.show("Task erfolgreich aktualisiert!");
                this.getOwnerComponent().getModel("tasks").loadData("/api/v1/tasks");
            }.bind(this));
        },
        onDelete: function () {
            var sTaskId = this.getView().getModel("detail").getProperty("/id");
            fetch("/api/v1/tasks/" + sTaskId, {
                method: "DELETE"
            }).then(function () {
                MessageToast.show("Task gelöscht!");
                this.getOwnerComponent().getModel("tasks").loadData("/api/v1/tasks");
                this.getOwnerComponent().getRouter().navTo("master");
            }.bind(this));
        }
    });
});