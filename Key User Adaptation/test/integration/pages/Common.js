/* global QUnit */
sap.ui.define([
	"sap/ui/test/Opa5",
	"sap/ui/fl/FakeLrepConnectorSessionStorage",
	"sap/ui/test/actions/Press"
], function (
	Opa5,
	FakeLrepConnectorSessionStorage,
	Press
) {
	"use strict";

	function getFrameUrl(sHash, sUrlParameters, sTechnicalParameters) {
		var sUrl = sap.ui.require.toUrl(this.sUrl + ".html");
		sHash = sHash || "";
		sUrlParameters = sUrlParameters ? "?" + sUrlParameters : "";
		sTechnicalParameters = sTechnicalParameters ? "?" + sTechnicalParameters : "";

		if (sHash) {
			var sHashPrefix = this.sUrlHashPrefix ? this.sUrlHashPrefix + "&/" : "/";
			sHash = sHashPrefix + (sHash.indexOf("/") === 0 ? sHash.substring(1) : sHash);
		} else {
			sHash = this.sUrlHashPrefix;
		}

		var aHashParts = sHash.split("&");
		aHashParts[1] = aHashParts[1] ? '&' + aHashParts[1] : "";

		return sUrl + sUrlParameters + aHashParts[0] + sTechnicalParameters + aHashParts[1];
	}

	function validateProperties() {
		if (this.sUrl && typeof this.sUrl !== "string") {
			throw new Error("Can't start test without valid URL. Please provide the 'url' settings property!");
		}
		if (this.sUrlHashPrefix && typeof this.sUrlHashPrefix !== "string") {
			throw new Error("'urlHashPrefix' should be a string istead of '" + typeof this.sUrlHashPrefix + "'");
		}
		if (this.sMockserverPath && typeof this.sMockserverPath !== "string") {
			throw new Error("Mockserver path should be a string instead of '" + typeof this.sMockserverPath + "'");
		}
	}

	/**
	 * Constructor for OPA5 common pages class.
	 *
	 * @param {object} mSettings - initial settings
	 * @param {function} mSettings.url - url string without querry parameters
	 * @param {function} [this.sUrlHashPrefix] - prefix of the url hash string without querry parameters
	 * @param {string} [this.sMockserverPath] - path to mockserver
	 *
	 * @class
	 * @extends sap.ui.test.Opa5
	 *
	 * @author SAP SE
	 * @version 1.120.50
	 *
	 * @constructor
	 * @private
	 * @since 1.89
	 */
	return Opa5.extend("sap.ui.demoapps.rta.test.integration.pages.Common", {

		constructor: function () {
			validateProperties.call(this);
			Opa5.apply(this, arguments);
		},

		iStartTheApp: function (oOptions) {
			oOptions = oOptions || {};
			this.iStartMyAppInAFrame({
				source: getFrameUrl.call(this, oOptions.hash, oOptions.urlParameters, oOptions.technicalParameters),
				autoWait: true
			});
		},

		iClearTheSessionLRep: function () {
			FakeLrepConnectorSessionStorage.forTesting.synchronous.clearAll();
			window.sessionStorage.removeItem("sap.ui.rta.restart.CUSTOMER");
			window.sessionStorage.removeItem("sap.ui.rta.restart.USER");
		},

		iAddTheVariantURLParameter: function () {
			Object.keys(window.sessionStorage).some(function (key) {
				if (key.includes("sap.ui.fl.variant.id")) {
					Opa5.getContext().variantId = JSON.parse(window.sessionStorage[key]).fileName;
					return true;
				}
				return false;
			});
		},

		iStartTheAppWithDelay: function (sHash, iDelay) {
			this.iStartMyAppInAFrame(getFrameUrl.call(this, sHash, "serverDelay=" + iDelay));
		},

		iLookAtTheScreen: function () {
			return this;
		},

		iStartMyAppOnADesktopToTestErrorHandler: function (sParam) {
			this.iStartMyAppInAFrame(getFrameUrl.call(this, "", sParam));
		},

		createAWaitForAnEntitySet: function (oOptions) {
			return {
				success: function () {
					var bMockServerAvailable = false;
					var aEntitySet;

					this.getMockServer().then(function (oMockServer) {
						aEntitySet = oMockServer.getEntitySetData(oOptions.entitySet);
						bMockServerAvailable = true;
					});

					return this.waitFor({
						check: function () {
							return bMockServerAvailable;
						},
						success: function () {
							oOptions.success.call(this, aEntitySet);
						}
					});
				}
			};
		},

		getMockServer: function () {
			return new Promise(function (success) {
				if (!this.sMockserverPath) {
					throw new Error("Not able to get mock server. The mock server path is not available");
				}
				Opa5.getWindow().sap.ui.require([this.sMockserverPath], function (mockserver) {
					success(mockserver.getMockServer());
				});
			});
		},

		theUnitNumbersShouldHaveTwoDecimals: function (sControlType, sViewName, sSuccessMsg, sErrMsg) {
			var rTwoDecimalPlaces = /^-?\d+\.\d{2}$/;

			return this.waitFor({
				controlType: sControlType,
				viewName: sViewName,
				success: function (aNumberControls) {
					QUnit.assert.ok(aNumberControls.every(function (oNumberControl) {
						return rTwoDecimalPlaces.test(oNumberControl.getNumber());
					}), sSuccessMsg);
				},
				errorMessage: sErrMsg
			});
		},

		iTeardownTheAppFrame: function(sId, sViewName, bVisible, bResetStorage) {
			return this.waitFor({
				id: sId,
				viewName: sViewName,
				visible: bVisible,
				success: function() {
					if (bResetStorage) {
						FakeLrepConnectorSessionStorage.forTesting.setStorage(window.sessionStorage);
					}
					return this.iTeardownMyAppFrame();
				}
			});
		},

		iEnableTheSessionStorage: function (sId, sViewName) {
			return this.waitFor({
				id: sId,
				viewName: sViewName,
				success: function () {
					FakeLrepConnectorSessionStorage.enableFakeConnector();
				}
			});
		}
	});
});
