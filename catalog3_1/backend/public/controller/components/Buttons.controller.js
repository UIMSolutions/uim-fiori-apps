sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("my.app.controller.components.Buttons", {
        
        onDrillDown: function (oEvent) {
            // Get the title of the clicked list item (e.g., "Events" or "Properties")
            var oItem = oEvent.getSource();
            var sSubItemId = oItem.getTitle().toLowerCase();

            var oRouter = this.getOwnerComponent().getRouter();
            
            // Navigate to the 3rd level route defined in manifest.json
            oRouter.navTo("subDetail", {
                componentId: "buttons",
                subItemId: sSubItemId,
                layout: "ThreeColumnsEndExpanded"
            });
        }
        
    });
});