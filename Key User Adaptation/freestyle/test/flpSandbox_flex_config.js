(function() {
	"use strict";

	globalThis["sap-ui-config"] ??= {};
	globalThis["sap-ui-config"].flexibilityServices = [
		{
			connector: "SessionStorageConnector"
		}
	];
}());
