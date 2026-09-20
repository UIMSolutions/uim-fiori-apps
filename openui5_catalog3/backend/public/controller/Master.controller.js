sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator"
], function (Controller, JSONModel, Filter, FilterOperator) {
    "use strict";

    return Controller.extend("my.app.controller.Master", {
        onInit: function () {
            var oModel = new JSONModel("/api/components");
            this.getView().setModel(oModel);
        },
        
        onSelectNamespace: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var sNamespaceId = oItem.getBindingContext().getProperty("id");
            
            this.getOwnerComponent().getRouter().navTo("detail", {
                namespaceId: sNamespaceId,
                layout: "TwoColumnsMidExpanded"
            });
        },

        onSearch: function (oEvent) {
            // Get the search query string (supports live typing or clicking clear)
            var sQuery = oEvent.getParameter("query") || oEvent.getParameter("newValue");
            var aFilters = [];

            if (sQuery && sQuery.length > 0) {
                // Filter by name or description (case-insensitive search)
                var oFilterName = new Filter("name", FilterOperator.Contains, sQuery);
                var oFilterDesc = new Filter("description", FilterOperator.Contains, sQuery);
                
                // Combine them with an OR operator so it matches either field
                var oCombinedFilter = new Filter({
                    filters: [oFilterName, oFilterDesc],
                    and: false
                });
                
                aFilters.push(oCombinedFilter);
            }

            // Update list binding
            var oList = this.byId("namespaceList");
            var oBinding = oList.getBinding("items");
            oBinding.filter(aFilters);
        }
    });
});