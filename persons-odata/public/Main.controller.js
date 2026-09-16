sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";
    return Controller.extend("personapp.Main", {
        onInit: function () {
            // Lokales JSON-Modell für das Formular
            this.getView().setModel(new JSONModel({ Name: "", Email: "", Role: "" }), "newPerson");
        },
        onAddPerson: function () {
            var oView = this.getView();
            var oNewPersonModel = oView.getModel("newPerson");
            var oData = oNewPersonModel.getData();
            if (!oData.Name || !oData.Email) {
                MessageToast.show("Bitte Name und E-Mail eingeben!");
                return;
            }
            // OData V4 ListBinding für das Erstellen nutzen
            var oTable = oView.byId("personTable");
            var oListBinding = oTable.getBinding("items");
            var oContext = oListBinding.create({
                "Name": oData.Name,
                "Email": oData.Email,
                "Role": oData.Role || ""
            });
            oContext.created().then(function () {
                MessageToast.show("Person via OData V4 angelegt");
                oNewPersonModel.setData({ Name: "", Email: "", Role: "" });
            }).catch(function (oError) {
                MessageToast.show("Fehler beim Anlegen: " + oError.message);
            });
        },
        onDeletePerson: function (oEvent) {
            var oContext = oEvent.getSource().getBindingContext();
            
            // OData V4 native Löschfunktion auf dem Context
            oContext.delete().then(function () {
                MessageToast.show("Person via OData V4 gelöscht");
            }).catch(function (oError) {
                MessageToast.show("Fehler beim Löschen: " + oError.message);
            });
        }
    });
});