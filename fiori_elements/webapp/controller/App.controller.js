sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
	"use strict";

	return Controller.extend("vibe.demo.controller.App", {
		onInit: function () {
			this.getOwnerComponent().getRouter().attachRouteMatched(function (oEvent) {
				this.byId("nav").setSelectedKey(oEvent.getParameter("name"));
			}, this);
		},

		onTabSelect: function (oEvent) {
			this.getOwnerComponent().getRouter().navTo(oEvent.getParameter("key"));
		},

		onNavHome: function () {
			this.getOwnerComponent().getRouter().navTo("home");
		}
	});
});
