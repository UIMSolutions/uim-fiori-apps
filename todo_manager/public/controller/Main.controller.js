sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("todo.app.controller.Main", {

        onAddTask: function (oEvent) {
            if (oEvent && oEvent.preventDefault) {
                oEvent.preventDefault();
            }
            
            var oInputTitle = this.byId("taskTitleInput");
            var oInputDesc = this.byId("taskDescriptionInput");

            var sTitle = oInputTitle.getValue().trim();
            var sDescription = oInputDesc.getValue().trim();

            if (!sTitle) {
                MessageToast.show("Bitte einen Titel eingeben.");
                return;
            }

            var oList = this.byId("taskList");
            var oBinding = oList.getBinding("items");

            // Eingabefelder direkt leeren
            oInputTitle.setValue("");
            if (oInputDesc) {
                oInputDesc.setValue("");
            }

            // Eintrag mit Titel & Beschreibung erstellen
            var oContext = oBinding.create({
                title: sTitle,
                description: sDescription,
                isCompleted: false
            }, false, true);

            oContext.created().then(function () {
                MessageToast.show("Aufgabe erfolgreich gespeichert");
            }).catch(function (oError) {
                if (oContext.isTransient()) {
                    oContext.delete();
                }
                MessageToast.show("Fehler beim Speichern");
            });
        },

        onToggleCompleted: function (oEvent) {
            var oContext = oEvent.getSource().getBindingContext();
            var bSelected = oEvent.getParameter("selected");

            oContext.setProperty("isCompleted", bSelected);
        }
    });
});