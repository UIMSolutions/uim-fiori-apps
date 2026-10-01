sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("reqmgmt.controller.Main", {
        onInit: function () {
            this._oRouter = this.getOwnerComponent().getRouter();
        },

        onNavigateToProjects: function () {
            this._oRouter.navTo("RouteProjects");
        },

        onNavigateToBusinessReqs: function () {
            this._oRouter.navTo("RouteBusinessReqs");
        },

        onNavigateToSolutionReqs: function () {
            this._oRouter.navTo("RouteSolutionReqs");
        }
    });
});