sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Configuration", {
        onInit: function () {
            this._setDefaultModel();
        },

        onSave: function () {
            MessageToast.show("Konfiguration gespeichert.");
        },

        onReset: function () {
            this._setDefaultModel();
            MessageToast.show("Konfiguration zurueckgesetzt.");
        },

        _setDefaultModel: function () {
            var oConfigModel = new JSONModel({
                systemName: "Architecture Manager",
                defaultLanguage: "de",
                mailNotifications: true,
                autoSync: false
            });

            this.getView().setModel(oConfigModel, "config");
        }
    });
});
