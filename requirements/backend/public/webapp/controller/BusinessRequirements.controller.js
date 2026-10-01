sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageToast",
  "sap/m/MessageBox",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Input",
  "sap/m/Label",
  "sap/m/TextArea",
  "sap/m/Select",
  "sap/ui/core/Item",
  "sap/ui/layout/form/SimpleForm"
], function (Controller, MessageToast, MessageBox, Dialog, Button, Input, Label, TextArea, Select, Item, SimpleForm) {
  "use strict";

  return Controller.extend("requirements.controller.BusinessRequirements", {
    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavProjects: function () {
      this.getOwnerComponent().getRouter().navTo("projects");
    },

    onNavSolution: function () {
      this.getOwnerComponent().getRouter().navTo("solution");
    },

    onCreate: function () {
      var oModel = this.getView().getModel();
      var oDialog = new Dialog({
        title: "Geschäftsanforderung anlegen",
        contentWidth: "36rem",
        content: [
          new SimpleForm({
            editable: true,
            content: [
              new Label({ text: "ID" }),
              new Input("businessIdInput", { placeholder: "optional" }),
              new Label({ text: "Titel" }),
              new Input("businessTitleInput"),
              new Label({ text: "Beschreibung" }),
              new TextArea("businessDescInput", { rows: 4 }),
              new Label({ text: "Kategorie" }),
              new Input("businessCategoryInput", { value: "Business" }),
              new Label({ text: "Projekt" }),
              new Select("businessProjectInput", {
                items: {
                  path: "/Projects",
                  template: new Item({ key: "{ID}", text: "{Name} ({ID})" })
                }
              })
            ]
          })
        ],
        beginButton: new Button({
          text: "Speichern",
          type: "Emphasized",
          press: function () {
            var oPayload = {
              ID: sap.ui.getCore().byId("businessIdInput").getValue(),
              Title: sap.ui.getCore().byId("businessTitleInput").getValue(),
              Description: sap.ui.getCore().byId("businessDescInput").getValue(),
              Category: sap.ui.getCore().byId("businessCategoryInput").getValue() || "Business",
              ProjectID: sap.ui.getCore().byId("businessProjectInput").getSelectedKey()
            };

            if (!oPayload.Title || !oPayload.ProjectID) {
              MessageBox.error("Titel und Projekt sind erforderlich");
              return;
            }

            var oCtx = oModel.bindList("/BusinessRequirements").create(oPayload);
            oCtx.created().then(function () {
              MessageToast.show("Geschäftsanforderung angelegt");
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
      var oItem = this.byId("businessTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show("Bitte eine Geschäftsanforderung auswählen");
        return;
      }

      var oCtx = oItem.getBindingContext();
      oCtx.delete("$auto").then(function () {
        MessageToast.show("Geschäftsanforderung gelöscht");
      }).catch(function (oErr) {
        MessageBox.error("Löschen fehlgeschlagen: " + (oErr.message || "Unbekannt"));
      });
    }
  });
});
