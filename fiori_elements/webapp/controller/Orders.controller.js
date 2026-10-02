sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/model/Filter",
	"sap/ui/model/FilterOperator"
], function (Controller, Filter, FilterOperator) {
	"use strict";

	return Controller.extend("vibe.demo.controller.Orders", {
		onSearch: function (oEvent) {
			var sQuery = oEvent.getParameter("query");
			this.byId("table").getBinding("items")
				.filter(sQuery ? new Filter("Customer", FilterOperator.Contains, sQuery) : []);
		}
	});
});
