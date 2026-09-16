sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator"
], function (Controller, Filter, FilterOperator) {
    "use strict";
    return Controller.extend("taskmanager.fiori.controller.Master", {
        onTaskPress: function (oEvent) {
            var oItem = oEvent.getSource();
            var oContext = oItem.getBindingContext("tasks");
            var sTaskId = oContext.getProperty("id");
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.navTo("detail", {
                taskId: sTaskId
            });
        },
        onSearch: function (oEvent) {
            var sQuery = oEvent.getParameter("query");
            var aFilter = [];
            if (sQuery) {
                aFilter.push(new Filter("title", FilterOperator.Contains, sQuery));
            }
            var oList = this.byId("taskList");
            var oBinding = oList.getBinding("items");
            oBinding.filter(aFilter);
        }
    });
});