sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/routing/History"
], function(Controller, History) {
    "use strict";
    return Controller.extend("sap.m.sample.TileContainer.Page", {
        onInit: function () {
            this.getOwnerComponent().getRouter().getRoute("detail").attachPatternMatched(this._onDetailMatched, this);
        },
        onTilePress: function (oEvent) {
            var oCtx = oEvent.getSource().getBindingContext();
            if (!oCtx) {
                return;
            }
            var sTileId = oCtx.getProperty("ID");
            this.getOwnerComponent().getRouter().navTo("detail", {
                tileId: encodeURIComponent(sTileId)
            });
        },
        _onDetailMatched: function (oEvent) {
            var sTileId = decodeURIComponent(oEvent.getParameter("arguments").tileId);
            var sPath = "/Tiles('" + sTileId + "')";
            if (this.getView().getViewName() === "sap.m.sample.TileContainer.Detail") {
                this.getView().bindElement({
                    path: sPath
                });
            }
        },
        onNavBack: function () {
            var oHistory = History.getInstance();
            var sPreviousHash = oHistory.getPreviousHash();
            if (sPreviousHash !== undefined) {
                window.history.back();
            } else {
                this.getOwnerComponent().getRouter().navTo("tiles", {}, true);
            }
        }
    });
});