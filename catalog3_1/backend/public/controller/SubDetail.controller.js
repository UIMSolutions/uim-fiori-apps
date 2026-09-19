sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Fragment"
], function (Controller, Fragment) {
    "use strict";

    return Controller.extend("my.app.controller.SubDetail", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("subDetail").attachPatternMatched(this._onRouteMatched, this);
        },

        _onRouteMatched: function (oEvent) {
            var oArgs = oEvent.getParameter("arguments");
            var sSubItemId = oArgs.subItemId; 
            var oPage = this.byId("subDynamicPage");

            // Capitalize for filename mapping (e.g., "events" -> "Events")
            var sFragmentName = sSubItemId.charAt(0).toUpperCase() + sSubItemId.slice(1);
            
            oPage.setTitle(sFragmentName + " Configuration");
            oPage.destroyContent();

            // Use the modern, View-bound fragment loader
            this.loadFragment({
                name: "my.app.view.fragments." + sFragmentName
            }).then(function (oFragment) {
                oPage.addContent(oFragment);
            }).catch(function (oError) {
                // Now we will see exactly WHY it failed in the F12 console
                console.error("Failed to load fragment specifically because:", oError);
            });
        },  

        onCloseSubDetail: function () {
            // Extract the current componentId from the hash to route back correctly
            var aHashParts = this.getOwnerComponent().getRouter().getHashChanger().getHash().split("/");
            
            this.getOwnerComponent().getRouter().navTo("detail", {
                componentId: aHashParts[1], 
                layout: "TwoColumnsMidExpanded"
            });
        }
    });
});