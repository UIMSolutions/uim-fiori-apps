sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (Controller, Filter, FilterOperator) {
  "use strict";

  return Controller.extend("uml.controller.Library", {
    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavWorkspace: function () {
      this.getOwnerComponent().getRouter().navTo("workspace");
    },

    onNavInsights: function () {
      this.getOwnerComponent().getRouter().navTo("insights");
    },

    onSearch: function (oEvent) {
      var sValue = oEvent.getParameter("newValue") || "";
      var oBinding = this.byId("libraryList").getBinding("items");

      if (!sValue) {
        oBinding.filter([]);
        return;
      }

      oBinding.filter([
        new Filter({
          filters: [
            new Filter("Name", FilterOperator.Contains, sValue),
            new Filter("Project", FilterOperator.Contains, sValue),
            new Filter("DiagramType", FilterOperator.Contains, sValue)
          ],
          and: false
        })
      ]);
    }
  });
});
