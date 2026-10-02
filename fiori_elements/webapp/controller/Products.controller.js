sap.ui.define(["vibe/demo/controller/CrudController"], function (CrudController) {
	"use strict";

	return CrudController.extend("vibe.demo.controller.Products", {
		exportName: "products",
		titleKey: "productsTab",
		exportColumns: [["ID", "colId"], ["Name", "colName"], ["Category", "colCategory"], ["Price", "colPrice"], ["Currency", "colCurrency"], ["Stock", "colStock"], ["Rating", "colRating"]],
		fragmentName: "vibe.demo.view.ProductDialog",
		searchField: "Name",
		requiredField: "Name",
		labelField: "Name",
		numberFields: ["Price", "Stock", "Rating"],
		defaults: { Name: "", Category: "", Price: 0, Currency: "EUR", Stock: 0, Rating: 3 }
	});
});
