sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("my.app.Component", {
        metadata: { manifest: "json" },

        init: function () {
            // 1. Call the base class init first
            UIComponent.prototype.init.apply(this, arguments);

            // 2. Create and set the FCL layout model
            var oLayoutModel = new JSONModel({ layout: "OneColumn" });
            this.setModel(oLayoutModel, "fclLayout");

            // 3. Get the router safely using UI5's built-in helper
            var oRouter = this.getRouter();
            
            if (oRouter) {
                // Attach the layout switcher to route changes
                oRouter.attachRouteMatched(function (oEvent) {
                    var sLayout = oEvent.getParameter("arguments").layout;
                    oLayoutModel.setProperty("/layout", sLayout || "OneColumn");
                }, this);

                // Initialize the router
                oRouter.initialize();
            } else {
                console.error("Router could not be initialized. Check your manifest.json routing configuration.");
            }
        }
    });
});