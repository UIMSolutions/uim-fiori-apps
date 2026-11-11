sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/f/library"
], function (Controller, fLibrary) {
    "use strict";

    var LayoutType = fLibrary.LayoutType;

    return Controller.extend("ea.architecture.manager.controller.InterfaceMasterDetail", {

        onListItemPress: function (oEvent) {
            var oItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oItem.getBindingContext(); // Liefert den OData v4 Context

            if (oContext) {
                // Detailbereich mit dem OData v4 Context des Listenelements verknüpfen
                var oDetailPage = this.byId("detailPage");
                oDetailPage.setBindingContext(oContext);

                // Layout auf zweispaltig erweitern
                var oFCL = this.byId("fcl");
                oFCL.setLayout(LayoutType.TwoColumnsMidExpanded);
            }
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});