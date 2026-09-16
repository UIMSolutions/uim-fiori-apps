sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";
    return Controller.extend("personapp.Main", {
        onInit: function () {
            this.getView().setModel(new JSONModel({ name: "", email: "", role: "" }), "newPerson");
            this.loadPersons();
        },
        loadPersons: function () {
            var oModel = new JSONModel();
            oModel.loadData("/api/persons");
            this.getView().setModel(oModel, "persons");
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
            }).then(function () {
                MessageToast.show("Person erfolgreich angelegt");
                oNewPersonModel.setData({ name: "", email: "", role: "" });
                this.loadPersons();
            }.bind(this));
        },
        onDeletePerson: function (oEvent) {
            var oItem = oEvent.getSource().getBindingContext("persons").getObject();
            fetch("/api/persons/" + oItem.id, {
                method: "DELETE"
            }).then(function () {
                MessageToast.show("Person gelöscht");
                this.loadPersons();
            }.bind(this));
        }
    });
});