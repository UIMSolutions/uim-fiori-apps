sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("pm.fiori.controller.Main", {
        onInit: function () {
            var oModel = new JSONModel();
            
            // Abruf der PM-Daten vom vibe.d REST Backend
            oModel.loadData("/api/v1/project/dashboard")
                .then(function () {
                    MessageToast.show("Daten erfolgreich vom vibe.d Backend geladen.");
                }.bind(this))
                .catch(function (oError) {
                    MessageToast.show("Fehler beim Laden der Daten vom Backend.");
                });

            this.getView().setModel(oModel, "pmModel");
        }
    });
});
