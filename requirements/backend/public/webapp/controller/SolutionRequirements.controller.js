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

  return Controller.extend("requirements.controller.SolutionRequirements", {
    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavProjects: function () {
      this.getOwnerComponent().getRouter().navTo("projects");
    },

    onNavBusiness: function () {
      this.getOwnerComponent().getRouter().navTo("business");
    },

    onCreate: function () {
      var oModel = this.getView().getModel();
      var oDialog = new Dialog({
        title: "Lösungsanforderung anlegen",
        contentWidth: "36rem",
        content: [
          new SimpleForm({
            editable: true,
            content: [
              new Label({ text: "ID" }),
              new Input("solutionIdInput", { placeholder: "optional" }),
              new Label({ text: "Titel" }),
              new Input("solutionTitleInput"),
              new Label({ text: "Beschreibung" }),
              new TextArea("solutionDescInput", { rows: 4 }),
              new Label({ text: "Kategorie" }),
              new Input("solutionCategoryInput", { value: "Solution" }),
              new Label({ text: "Projekt" }),
              new Select("solutionProjectInput", {
                items: {
                  path: "/Projects",
                  template: new Item({ key: "{ID}", text: "{Name} ({ID})" })
                }
              }),
              new Label({ text: "Parent Business Requirement" }),
              new Select("parentBusinessInput", {
                items: {
                  path: "/BusinessRequirements",
                  template: new Item({ key: "{ID}", text: "{Title} ({ID})" })
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
              ID: sap.ui.getCore().byId("solutionIdInput").getValue(),
              Title: sap.ui.getCore().byId("solutionTitleInput").getValue(),
              Description: sap.ui.getCore().byId("solutionDescInput").getValue(),
              Category: sap.ui.getCore().byId("solutionCategoryInput").getValue() || "Solution",
              ProjectID: sap.ui.getCore().byId("solutionProjectInput").getSelectedKey(),
              ParentBusinessRequirementID: sap.ui.getCore().byId("parentBusinessInput").getSelectedKey()
            };

            if (!oPayload.Title || !oPayload.ProjectID || !oPayload.ParentBusinessRequirementID) {
              MessageBox.error("Titel, Projekt und Parent Business Requirement sind erforderlich");
              return;
            }

            var oCtx = oModel.bindList("/SolutionRequirements").create(oPayload);
            oCtx.created().then(function () {
              MessageToast.show("Lösungsanforderung angelegt");
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
      var oItem = this.byId("solutionTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show("Bitte eine Lösungsanforderung auswählen");
        return;
      }

      var oCtx = oItem.getBindingContext();
      oCtx.delete("$auto").then(function () {
        MessageToast.show("Lösungsanforderung gelöscht");
      }).catch(function (oErr) {
        MessageBox.error("Löschen fehlgeschlagen: " + (oErr.message || "Unbekannt"));
      });
    }
  });
});
