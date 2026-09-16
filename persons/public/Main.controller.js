sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";
    return Controller.extend("personapp.Main", {
        onInit: function () {
            // Modell für neue Eingaben initialisieren
            this.getView().setModel(new JSONModel({ name: "", email: "", role: "" }), "newPerson");
            
            // Modell für Personenliste initialisieren (leeres Array)
            this.getView().setModel(new JSONModel([]), "persons");
            
            // Daten laden
            this.loadPersons();
        },
        loadPersons: function () {
            var that = this;
            fetch("/api/persons")
                .then(function (response) { return response.json(); })
                .then(function (data) {
                    // Wir setzen das empfangene Array direkt in ein Modell namens "persons"
                    var oModel = new JSONModel(data);
                    that.getView().setModel(oModel, "persons");
                });
        },
        onAddPerson: function () {
            var oNewPersonModel = this.getView().getModel("newPerson");
            var oData = oNewPersonModel.getData();
            if (!oData.name || !oData.email) {
                MessageToast.show("Bitte Name und E-Mail eingeben!");
                return;
            }
            fetch("/api/persons", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(oData)
            }).then(function (res) {
                if (res.ok) {
                    MessageToast.show("Person erfolgreich angelegt");
                    oNewPersonModel.setData({ name: "", email: "", role: "" });
                    this.loadPersons();
                }
            }.bind(this));
        },
        onDeletePerson: function (oEvent) {
            var oItem = oEvent.getSource().getBindingContext("persons").getObject();
            fetch("/api/persons/" + oItem.id, {
                method: "DELETE"
            }).then(function (res) {
                if (res.ok) {
                    MessageToast.show("Person gelöscht");
                    this.loadPersons();
                }
            }.bind(this));
        }
    });
});