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

    return Controller.extend("projects.app.controller.Detail", {
        onDeleteTodo: function (oEvent) {
            var oContext = oEvent.getSource().getBindingContext();
            if (!oContext) {
                console.error("Kein Binding Context vorhanden!");
                return;
            }
            
            oContext.delete().then(function () {
                MessageToast.show("Todo gelöscht");
            });
        },

        onOpenAddTodoDialog: function () {
            var that = this;
            var oTitleInput = new Input({ placeholder: "Todo Titel" });

            var oDialog = new Dialog({
                title: "Neues Todo hinzufügen",
                content: new VBox({ items: [new Label({ text: "Aufgabe:" }), oTitleInput] }),
                beginButton: new Button({
                    text: "Hinzufügen",
                    press: function () {
                        var oContext = that.getView().getBindingContext();
                        var iProjectId = oContext.getProperty("Id");
                        
                        // Binding der Todo-Tabelle abrufen
                        var oTable = that.byId("todoTable");
                        var oBinding = oTable.getBinding("items");

                        oBinding.create({
                            ProjectId: iProjectId,
                            Title: oTitleInput.getValue()
                        });

                        MessageToast.show("Todo hinzugefügt");
                        oDialog.close();
                    }
                }),
                endButton: new Button({ press: function () { oDialog.close(); }, text: "Abbrechen" }),
                afterClose: function () { oDialog.destroy(); }
            });

            this.getView().addDependent(oDialog);
            oDialog.open();
        }
    });
});