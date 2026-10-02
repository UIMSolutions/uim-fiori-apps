sap.ui.define(["vibe/demo/controller/CrudController"], function (CrudController) {
	"use strict";

	return CrudController.extend("vibe.demo.controller.Orders", {
		exportName: "orders",
		titleKey: "ordersTab",
		exportColumns: [["ID", "colOrder"], ["Customer", "colCustomer"], ["OrderDate", "colDate"], ["ProductID", "colProduct"], ["Quantity", "colQuantity"], ["Total", "colTotal"], ["Currency", "colCurrency"], ["Status", "colStatus"]],
		fragmentName: "vibe.demo.view.OrderDialog",
		searchField: "Customer",
		requiredField: "Customer",
		labelField: "ID",
		numberFields: ["ProductID", "Quantity", "Total"],
		defaults: { Customer: "", ProductID: 1, Quantity: 1, Total: 0, Currency: "EUR", Status: "Open", OrderDate: new Date().toISOString().slice(0, 10) }
	});
});
