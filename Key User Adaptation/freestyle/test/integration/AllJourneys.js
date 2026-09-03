sap.ui.define([
	"sap/ui/test/Opa5",
	"./pages/Common",
	"./pages/Browser",
	"./pages/Master",
	"./pages/NotFound",
	"./pages/ProductMaster",
	"./pages/ProductDisplay",
	"./pages/ChangeVisualization",
	"./ProductMasterJourney",
	"./NotFoundJourney",
	"./RTAJourney",
	"./ChangeVisualizationJourney",
	"./IFrameJourney",
	"./RTAPersonalizationJourney",
	"sap/ui/demoapps/rta/test/integration/pages/IFrame",
	"sap/ui/demoapps/rta/test/integration/pages/Shared",
	"sap/ui/rta/test/internal/integration/pages/Adaptation"
], function(Opa5, Common) {
	"use strict";

	Opa5.extendConfig({
		arrangements: new Common(),
		viewNamespace: "sap.ui.demoapps.rta.freestyle.view.",
		autoWait: true,
		asyncPolling: true,
		timeout: 100
	});
});
