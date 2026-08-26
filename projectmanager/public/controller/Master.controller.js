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
            console.log("onInit getriggert!");
            
            // Event an den EventBus senden
            sap.ui.getCore().getEventBus().publish("ProjectChannel", "ProjectUpdated");
            // var oList = this.byId("projectList");
            // if (oList) {
            //     oList.bindItems({
            //         path: "/Projects",
            //         template: new sap.m.StandardListItem({
            //             title: "{Name}",
            //             description: "{Description}"
            //         })
            //     });
            // }
        },
        
        onItemPress: function (oEvent) {
            console.log("Master:onItemPress getriggert!");

            // Hole die selektierte Context-ID aus dem Event (z.B. ID = "1" oder 1)
            var oItem = oEvent.getSource();
            var oContext = oItem.getBindingContext();

            if (!oContext) {
                console.log("Master:onItemPress getriggert! Aber kein BindingContext gefunden.");
                return;
            }
            console.log("Master:onItemPress getriggert! Context:", oContext);

            // OData v4 Best Practice: Falls getProperty("Id") undefined ist,
            // holen wir die ID aus dem Binding-Pfad oder direkt aus dem Objekt
            var sProjectId = oContext.getProperty("Id") || oContext.getObject().Id;
            console.log("Navigiere zu Projekt:", sProjectId);

            // Navigiere zur Route "Detail" mit dem Parameter "projectId"
            this.getOwnerComponent().getRouter().navTo("Detail", {
                projectId: sProjectId
            });
        },

        onDeleteProject: function (oEvent) {
            console.log("onDeleteProject getriggert!");

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
            console.log("onOpenAddProjectDialog getriggert!");

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
        },

        // --- Projekt bearbeiten ---
        onOpenEditProjectDialog: function (oEvent) {
            // Verhindert, dass durch den Klick auf den Button auch die onItemPress-Navigation getriggert wird
            oEvent.cancelBubble(); 

            var oItem = oEvent.getSource();
            var oContext = oItem.getBindingContext();

            if (!oContext) {
                return;
            }

            var sCurrentName = oContext.getProperty("Name");
            var sCurrentDescription = oContext.getProperty("Description");

            var oNameInput = new Input({ value: sCurrentName });
            var oDescInput = new Input({ value: sCurrentDescription });

            var oDialog = new Dialog({
                title: "Projekt bearbeiten",
                content: new VBox({
                    items: [
                        new Label({ text: "Name:" }),
                        oNameInput,
                        new Label({ text: "Beschreibung:" }),
                        oDescInput
                    ]
                }),
                beginButton: new Button({
                    text: "Speichern",
                    type: "Emphasized",
                    press: function () {
                        // OData v4: Direct Property-Updates senden automatisch einen PATCH-Request ans Backend
                        oContext.setProperty("Name", oNameInput.getValue());
                        oContext.setProperty("Description", oDescInput.getValue());

                        MessageToast.show("Projekt aktualisiert");
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
        },

        _onProjectUpdated: function () {
            // Holt die Liste und frischt deren OData-Binding explizit auf
            var oList = this.byId("projectList"); // ID deiner sap.m.List in Master.view.xml
            if (oList) {
                var oBinding = oList.getBinding("items");
                if (oBinding) {
                    oBinding.refresh(); // Erzwingt einen frischen GET-Request für /Projects
                }
            }
        }
    });
});