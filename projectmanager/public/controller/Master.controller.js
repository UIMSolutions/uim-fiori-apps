sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/Input",
    "sap/m/Label",
    "sap/m/VBox"
], function (Controller, MessageToast, Dialog, Button, Input, Label, VBox) {
    "use strict";

    return Controller.extend("projects.app.controller.Master", {
        onInit: function () {
            var oList = this.byId("projectList");
            if (oList) {
                oList.bindItems({
                    path: "/Projects",
                    template: new sap.m.StandardListItem({
                        title: "{Name}",
                        description: "{Description}"
                    })
                });
            }
        },
        onSelect: function (oEvent) {
            var oItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oBindingContext = oItem.getBindingContext();
            
            if (!oBindingContext) {
                return;
            }

            var sPath = oBindingContext.getPath();
            
            // Kopplung an Detail-View
            var oSplitApp = this.getOwnerComponent().getRootControl().byId("splitApp");
            if (oSplitApp && oSplitApp.getDetailPages().length > 0) {
                var oDetailView = oSplitApp.getDetailPages()[0];
                oDetailView.bindElement({
                    path: sPath
                });
            }
        },

        onDeleteProject: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var oContext = oItem ? oItem.getBindingContext() : null;
            
            if (!oContext) {
                return;
            }

            // OData v4: Löschen direkt auf dem Context
            oContext.delete().then(function () {
                MessageToast.show("Projekt gelöscht");
            }).catch(function (oError) {
                MessageToast.show("Fehler beim Löschen: " + oError.message);
            });
        },

        onOpenAddProjectDialog: function () {
            var that = this;
            var oNameInput = new Input({ placeholder: "Projektname" });
            var oDescInput = new Input({ placeholder: "Beschreibung" });

            var oDialog = new Dialog({
                title: "Neues Projekt anlegen",
                content: new VBox({
                    items: [
                        new Label({ text: "Name:" }), oNameInput,
                        new Label({ text: "Beschreibung:" }), oDescInput
                    ]
                }),
                beginButton: new Button({
                    text: "Erstellen",
                    press: function () {
                        // Empfohlen: Nutzung des bestehenden Listen-Bindings der UI-Liste
                        var oList = that.getView().byId("projectList");
                        var oListBinding = oList ? oList.getBinding("items") : null;

                        // Fallback: Direkt über das OData v4 Model, falls Liste nicht gefunden wird
                        if (!oListBinding) {
                            var oModel = that.getOwnerComponent().getModel();
                            if (oModel) {
                                oListBinding = oModel.bindList("/Projects");
                            }
                        }

                        if (!oListBinding) {
                            MessageToast.show("Fehler: OData-Modell oder Listen-Binding nicht vorhanden.");
                            return;
                        }

                        // Entität erzeugen
                        oListBinding.create({
                            Name: oNameInput.getValue(),
                            Description: oDescInput.getValue()
                        });

                        MessageToast.show("Projekt angelegt");
                        oDialog.close();
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

            this.getView().addDependent(oDialog);
            oDialog.open();
        }
    });
});