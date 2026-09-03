/* global QUnit */
QUnit.config.autostart = false;

sap.ui.require([
	"sap/ui/core/Core",
	"sap/ui/demoapps/rta/freestyle/test/integration/AllJourneysPhone"
], function(Core) {
	"use strict";

	Core.ready().then(() => {
		QUnit.start();
	});
});