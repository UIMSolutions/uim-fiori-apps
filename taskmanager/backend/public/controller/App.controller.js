sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";
    return Controller.extend("taskmanager.fiori.controller.App", {
        onInit: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            // Event anbinden, wenn Routen gematcht werden
            oRouter.attachRouteMatched(this.onRouteMatched, this);
        },
        onRouteMatched: function (oEvent) {
            var sRouteName = oEvent.getParameter("name");
            var oLayout = this.byId("layout");
            if (sRouteName === "master") {
                // Nur Master-Spalte anzeigen
                oLayout.setLayout("OneColumn");
            } else if (sRouteName === "detail") {
                // Master und Detail nebeneinander anzeigen
                oLayout.setLayout("TwoColumnsMidExpanded");
            }
        }
    });
});