(function() {
	"use strict";

	globalThis["sap-ushell-config"] = {
		defaultRenderer : "fiori2",
		bootstrapPlugins: {
			"RuntimeAuthoringPlugin" : {
				component: "sap.ushell.plugins.rta",
				config: {
					validateAppVersion: false
				}
			},
			"PersonalizePlugin": {
				component: "sap.ushell.plugins.rta-personalize",
				config: {
					validateAppVersion: false
				}
			}
		},
		renderers: {
			fiori2: {
				componentData: {
					config: {
						enableMergeAppAndShellHeaders: true,
						search: "hidden"
					}
				}
			}
		},
		applications: {
			"masterDetail-display": {
				"additionalInformation": "SAPUI5.Component=sap.ui.demoapps.rta.freestyle",
				"applicationType": "URL",
				"url": "../",
				"description": "UI Adaptation at Runtime",
				"title": "Products Manage",
				"applicationDependencies": {
					"self": { name: "sap.ui.demoapps.rta.freestyle" },
					"manifest": true,
					"asyncHints": {
						"libs": [
							{ "name": "sap.ui.core" },
							{ "name": "sap.m" },
							{ "name": "sap.ui.layout" },
							{ "name": "sap.ui.comp" },
							{ "name": "sap.ui.generic.app" },
							{ "name": "sap.uxap" },
							{ "name": "sap.ui.rta" }
						]
					}
				}
			}
		},
		services: {
			NavTargetResolution: {
				config: {
					"allowTestUrlComponentConfig" : true,
					"enableClientSideTargetResolution": true
				}
			}
		}
	};
}());
