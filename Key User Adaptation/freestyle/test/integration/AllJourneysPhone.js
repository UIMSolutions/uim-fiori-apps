sap.ui.define([
	"sap/ui/test/Opa5",
	"./pages/Common",
	"./pages/Browser",
	"./pages/Master",
	"./pages/NotFound",
	"./NotFoundJourneyPhone"
], function(Opa5, Common) {
	"use strict";

	Opa5.extendConfig({
		arrangements: new Common(),
		viewNamespace: "sap.ui.demoapps.rta.freestyle.view."
	});
});
