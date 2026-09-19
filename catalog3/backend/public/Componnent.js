sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("my.app.Component", {
        metadata: { manifest: "json" },

        init: function () {
            UIComponent.prototype.init.apply(this, arguments);

            var oRouter = this.getRouter();
            var oLayoutModel = new JSONModel({ layout: "OneColumn" });
            
            this.setModel(oLayoutModel, "fclLayout");

            oRouter.attachRouteMatched(function (oEvent) {
                var sLayout = oEvent.getParameter("arguments").layout;
                oLayoutModel.setProperty("/layout", sLayout || "OneColumn");
            }, this);

            oRouter.initialize();
        }
    });
});