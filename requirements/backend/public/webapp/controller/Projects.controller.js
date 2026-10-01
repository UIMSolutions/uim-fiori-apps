sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageToast",
  "sap/m/MessageBox",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Input",
  "sap/m/Label",
  "sap/m/TextArea",
  "sap/ui/layout/form/SimpleForm"
], function (Controller, MessageToast, MessageBox, Dialog, Button, Input, Label, TextArea, SimpleForm) {
  "use strict";

  return Controller.extend("requirements.controller.Projects", {
    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavBusiness: function () {
      this.getOwnerComponent().getRouter().navTo("business");
    },

    onNavSolution: function () {
      this.getOwnerComponent().getRouter().navTo("solution");
    },

    onCreate: function () {
      var oModel = this.getView().getModel();
      var oDialog = new Dialog({
        title: "Projekt anlegen",
        contentWidth: "32rem",
        content: [
          new SimpleForm({
            editable: true,
            content: [
              new Label({ text: "ID" }),
              new Input("projectIdInput", { placeholder: "optional" }),
              new Label({ text: "Name" }),
              new Input("projectNameInput"),
              new Label({ text: "Beschreibung" }),
              new TextArea("projectDescInput", { rows: 4 })
            ]
          })
        ],
        beginButton: new Button({
          text: "Speichern",
          type: "Emphasized",
          press: function () {
            var oPayload = {
              ID: sap.ui.getCore().byId("projectIdInput").getValue(),
              Name: sap.ui.getCore().byId("projectNameInput").getValue(),
              Description: sap.ui.getCore().byId("projectDescInput").getValue()
            };

            if (!oPayload.Name) {
              MessageBox.error("Projektname ist erforderlich");
              return;
            }

            var oCtx = oModel.bindList("/Projects").create(oPayload);
            oCtx.created().then(function () {
              MessageToast.show("Projekt angelegt");
              oDialog.close();
            }).catch(function (oErr) {
              MessageBox.error("Fehler: " + (oErr.message || "Unbekannt"));
            });
          }
        }),
        endButton: new Button({
          text: "Abbrechen",
          press: function () {
            oDialog.close();
          }
        }),
        afterClose: function () {
          oDialog.destroy();
        }
      });

      oDialog.open();
    },

    onDelete: function () {
      var oItem = this.byId("projectsTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show("Bitte ein Projekt auswählen");
        return;
      }

      var oCtx = oItem.getBindingContext();
      MessageBox.confirm("Projekt löschen?", {
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        emphasizedAction: MessageBox.Action.DELETE,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.DELETE) {
            return;
          }

          oCtx.delete("$auto").then(function () {
            MessageToast.show("Projekt gelöscht");
          }).catch(function (oErr) {
            MessageBox.error("Löschen fehlgeschlagen: " + (oErr.message || "Unbekannt"));
          });
        }
      });
    }
  });
});
