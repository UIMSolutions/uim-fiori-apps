sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/Input",
    "sap/m/Label",
    "sap/m/VBox"
], function (Controller, JSONModel, MessageToast, Dialog, Button, Input, Label, VBox) {
    "use strict";

    return Controller.extend("projects.app.controller.Detail", {
        onInit: function () {
            var oDetailModel = this.getOwnerComponent().getModel("detail");
            this.getView().setModel(oDetailModel, "project");
        },

        onDeleteTodo: function (oEvent) {
            var oContext = oEvent.getSource().getBindingContext("project");
            var oTodo = oContext.getObject();
            var oProject = this.getView().getModel("project").getData();

            fetch(`/api/projects/${oProject.id}/todos/${oTodo.id}`, {
                method: "DELETE"
            }).then(function (res) {
                if (res.ok) {
                    MessageToast.show("Todo gelöscht");
                    // Lokales Model aktualisieren
                    oProject.todos = oProject.todos.filter(t => t.id !== oTodo.id);
                    this.getView().getModel("project").setData(oProject);
                }
            }.bind(this));
        },

        onOpenAddTodoDialog: function () {
            var that = this;
            var oTitleInput = new Input({ placeholder: "Todo Titel" });

            var oDialog = new Dialog({
                title: "Neues Todo hinzufügen",
                content: new VBox({
                    items: [
                        new Label({ text: "Aufgabe:" }),
                        oTitleInput
                    ]
                }),
                beginButton: new Button({
                    text: "Hinzufügen",
                    press: function () {
                        var oProject = that.getView().getModel("project").getData();
                        var oData = { title: oTitleInput.getValue() };

                        fetch(`/api/projects/${oProject.id}/todos`, {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify(oData)
                        }).then(res => res.json()).then(function (newTodo) {
                            MessageToast.show("Todo hinzugefügt");
                            oProject.todos.push(newTodo);
                            that.getView().getModel("project").refresh(true);
                            oDialog.close();
                        });
                    }
                }),
                endButton: new Button({
                    text: "Abbrechen",
                    press: function () { oDialog.close(); }
                }),
                afterClose: function () { oDialog.destroy(); }
            });

            this.getView().addDependent(oDialog);
            oDialog.open();
        }
    });
});