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

    return Controller.extend("projects.app.controller.Master", {
        onInit: function () {
            this._loadProjects();
        },

        _loadProjects: function () {
            var oModel = new JSONModel();
            oModel.loadData("/api/projects");
            this.getView().setModel(oModel, "projects");
        },

        onSelect: function (oEvent) {
            var oItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var sPath = oItem.getBindingContext("projects").getPath();
            var oSelectedProject = this.getView().getModel("projects").getProperty(sPath);

            this.getOwnerComponent().getModel("detail").setData(oSelectedProject);
        },

        onDeleteProject: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var oContext = oItem.getBindingContext("projects");
            var oProject = oContext.getObject();

            fetch("/api/projects/" + oProject.id, {
                method: "DELETE"
            }).then(function (res) {
                if (res.ok) {
                    MessageToast.show("Projekt gelöscht");
                    this._loadProjects();
                    // Detail-Ansicht leeren, falls das gelöschte Projekt offen war
                    this.getOwnerComponent().getModel("detail").setData({});
                } else {
                    MessageToast.show("Fehler beim Löschen");
                }
            }.bind(this));
        },

        onOpenAddProjectDialog: function () {
            var that = this;
            var oNameInput = new Input({ placeholder: "Projektname" });
            var oDescInput = new Input({ placeholder: "Beschreibung" });

            var oDialog = new Dialog({
                title: "Neues Projekt anlegen",
                content: new VBox({
                    items: [
                        new Label({ text: "Name:" }),
                        oNameInput,
                        new Label({ text: "Beschreibung:" }),
                        oDescInput
                    ]
                }),
                beginButton: new Button({
                    text: "Erstellen",
                    press: function () {
                        var oData = {
                            name: oNameInput.getValue(),
                            description: oDescInput.getValue()
                        };

                        fetch("/api/projects", {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify(oData)
                        }).then(function (res) {
                            if (res.ok) {
                                MessageToast.show("Projekt erstellt");
                                that._loadProjects();
                                oDialog.close();
                            }
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