/*global QUnit*/
sap.ui.define(
	["sap/ui/test/opaQunit"],
	function(opaTest) {
		"use strict";

		QUnit.module("RTA Personalization");

		// Show the master view with product list
		opaTest("Start RTA Personalization", function(Given, When, Then) {
			var sEncodedConnectorValue = encodeURI('[{"connector": "SessionStorageConnector"}]');

			// Arrangements
			Given.iStartTheApp({
				hash: "product/HT-1000",
				urlParameters: "sap-ui-flexibilityServices=" + sEncodedConnectorValue
			});
			Given.iEnableTheSessionStorage("idAppControl", "Root");
			Given.iClearTheSessionLRep();
			// Actions
			When.onPageWithRTA.iWaitUntilTheBusyIndicatorIsGone("idAppControl", "Root").
			and.iGoToMeArea().
			and.iPressOnAdaptUi(true);

			// Assertions
			Then.onPageWithRTA.iShouldSeeTheToolbar().
			and.iShouldSeeTheOverlayForTheApp("idAppControl", "Root");
		});

		opaTest("Remove an Object Page Section using Context Menu", function(Given, When, Then) {
			// Actions
			When.onPageWithRTA.iRightClickOnAnElementOverlay("application-masterDetail-display-component---ProductDetail--ObjectSectionSupplier").
			and.iClickOnAContextMenuEntry(1);
			//Assertions
			Then.onPageWithRTA.iShouldNotSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionSupplier");
		});

		opaTest("Add an Object Page Section using Context Menu", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iRightClickOnAnElementOverlay("application-masterDetail-display-component---ProductDetail--ObjectSectionGeneral").
			and.iClickOnAContextMenuEntry(0).
			and.iSelectAFieldByLabelInTheAddSectionDialog("Technical Data").
			and.iPressOK();

			//Assertions
			Then.onPageWithRTA.iShouldSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
		});

		opaTest("Move a section using cut&paste", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iRightClickOnAnElementOverlay("application-masterDetail-display-component---ProductDetail--ObjectSectionGeneral").
			and.iClickOnAContextMenuEntry(2).
			and.iRightClickOnAnElementOverlay("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical").
			and.iClickOnAContextMenuEntry(3);

			// Assertions
			Then.onAnyPage.theSectionShouldBeInTheFirstPosition("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
		});

		opaTest("Remove a section using Easy Remove", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iPressOnRemoveSection("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");

			// Assertions
			Then.onPageWithRTA.iShouldNotSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
		});

		opaTest("Add a section using Easy Add", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iPressOnAddSection("application-masterDetail-display-component---ProductDetail--ObjectSectionGeneral"). // The button under
			and.iSelectAFieldByLabelInTheAddSectionDialog("Technical Data").
			and.iPressOK();

			// Assertions
			Then.onPageWithRTA.iShouldSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
			Then.onAnyPage.theSectionShouldBeInTheFirstPosition("application-masterDetail-display-component---ProductDetail--ObjectSectionGeneral");
		});

		opaTest("Exit RTA Personalization", function(Given, When, Then) {
			When.onPageWithRTA.iExitRtaPersonalizationMode();

			Then.onPageWithRTA.iShouldSeeTheFLPToolbarAndChangesInLRep(2, "sap.ui.demoapps.rta.freestyle.Component");
		});

		opaTest("Start RTA", function(Given, When, Then) {
			// Actions
			When.onPageWithRTA.iWaitUntilTheBusyIndicatorIsGone("idAppControl", "Root").
			and.iGoToMeArea().
			and.iPressOnAdaptUi();

			// Assertions
			Then.onPageWithRTA.iShouldSeeThePopUp();
		});

		opaTest("App Reload without Personalization Changes (test reload)", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iPressOK().and.iWaitUntilTheBusyIndicatorIsGone("idAppControl", "Root");

			// Assertions
			Then.onPageWithRTA.iShouldSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionSupplier").
			and.iShouldNotSeeTheElement("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
			Then.onAnyPage.theSectionShouldBeInTheFirstPosition("application-masterDetail-display-component---ProductDetail--ObjectSectionGeneral");
		});

		opaTest("Exit RTA", function(Given, When, Then){
			// Actions - no changes were done after reload
			When.onPageWithRTA.iExitRtaMode(/*bDontSaveOnExit=*/false, /*bNoChanges=*/true);

			// Assertions
			Then.onPageWithRTA.iShouldSeeThePopUp();
		});

		opaTest("Start app again to see Personalization Changes", function(Given, When, Then){
			// Actions
			When.onPageWithRTA.iPressOK().and.iWaitUntilTheBusyIndicatorIsGone("idAppControl", "Root");

			// Assertions
			Then.onAnyPage.iShouldSeeTheSection("application-masterDetail-display-component---ProductDetail--ObjectSectionTechnical");
		});

		opaTest("I clear the Session Storage and tear down the app", function(Given, When, Then) {
			//Actions
			When.onPageWithRTA.clearChangesFromSessionStorage();

			// Assertions
			Then.onPageWithRTA.iShouldSeeTheFLPToolbarAndChangesInLRep(0, "sap.ui.demoapps.rta.freestyle.Component");

			Given.iTeardownTheAppFrame("idAppControl", "Root", true, true);
		});
	}
);