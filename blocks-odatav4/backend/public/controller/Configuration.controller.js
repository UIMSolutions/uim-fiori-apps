sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, JSONModel, MessageToast, MessageBox) {
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

        onShowInfoNotification: function () {
            MessageToast.show("Info: Hintergrundsynchronisation wird geprueft.");
        },

        onShowSuccessNotification: function () {
            MessageToast.show("Erfolg: Einstellungen wurden erfolgreich uebernommen.");
        },

        onShowWarningNotification: function () {
            MessageBox.warning("Warnung: Das Mail-Gateway antwortet verzoegert.");
        },

        onShowErrorNotification: function () {
            MessageBox.error("Fehler: Verbindung zum Benachrichtigungsdienst fehlgeschlagen.");
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
