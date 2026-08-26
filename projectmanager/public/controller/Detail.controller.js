sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/Input",      // 1. Modul importieren
    "sap/m/CheckBox",
    "sap/m/Label",
    "sap/m/VBox"
], function (Controller, MessageToast, Dialog, Button, Input, CheckBox, Label, VBox) { // 2. "Input" als Parameter aufnehmen
    "use strict";

    return Controller.extend("projects.app.controller.Detail", {
        
        // Formatter-Funktionen
        formatTodoStatusText: function (bCompleted) {
            console.log("Detail:formatTodoStatusText getriggert! bCompleted:", bCompleted);
            return (bCompleted === true || bCompleted === "true" || bCompleted === 1 || bCompleted === "Ja") ? "Erledigt" : "Offen";
        },

        formatTodoStatusState: function (bCompleted) {
            console.log("Detail:formatTodoStatusState getriggert! bCompleted:", bCompleted);
            return (bCompleted === true || bCompleted === "true" || bCompleted === 1 || bCompleted === "Ja") ? "Success" : "Warning";
        },

        onInit: function () {
            console.log("Detail:onInit getriggert!");

            var oRouter = this.getOwnerComponent().getRouter();
            // Vergewissere dich, dass "Detail" exakt dem "name" in manifest.json entspricht
            oRouter.getRoute("Detail").attachPatternMatched(this._onObjectMatched, this);
        },

        _onObjectMatched: function (oEvent) {
            console.log("Detail:_onObjectMatched getriggert!");

            var sProjectId = oEvent.getParameter("arguments").projectId;
            
            console.log("--> _onObjectMatched getriggert! ProjectID:", sProjectId);

            if (!sProjectId) {
                console.error("sProjectId ist undefined!");
                return;
            }

            // Direktes Re-Binding ohne unbindElement()
            this.getView().bindElement({
                path: "/Projects(" + sProjectId + ")",
                parameters: {
                    $expand: "Todos"
                }
            });
        },

        // --- Aufgabe hinzufügen ---
        onOpenAddTodoDialog: function () {
            console.log("Detail:onOpenAddTodoDialog getriggert!");

            var that = this;
            var oTitleInput = new Input({ placeholder: "Titel der Aufgabe" });

            var oDialog = new Dialog({
                title: "Neue Aufgabe erstellen",
                content: new VBox({
                    items: [
                        new Label({ text: "Titel:" }), 
                        oTitleInput
                    ]
                }),
                beginButton: new Button({
                    text: "Erstellen",
                    type: "Emphasized",
                    press: function () {
                        var sTitle = oTitleInput.getValue();
                        if (!sTitle) {
                            return;
                        }

                        // OData v4: Binden der Sub-Kollektion 'Todos' des aktuellen Projekts
                        var oTable = that.byId("Detail") || that.getView().findAggregatedObjects(true, function(o) { return o.isA("sap.m.Table"); })[0];
                        var oListBinding = oTable.getBinding("items");

                        oListBinding.create({
                            Title: sTitle,
                            Completed: false
                        });

                        MessageToast.show("Aufgabe angelegt");
                        oDialog.close();
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
        },

        // --- Aufgabe bearbeiten ---
        onOpenEditTodoDialog: function (oEvent) {
            console.log("Detail:onOpenEditTodoDialog getriggert!");
            
            var oItem = oEvent.getSource();
            var oContext = oItem.getBindingContext();
            
            if (!oContext) {
                return;
            }

            var sCurrentTitle = oContext.getProperty("Title");
            var bCurrentStatus = oContext.getProperty("Completed");

            var oTitleInput = new Input({ value: sCurrentTitle });
            var oStatusCheckBox = new CheckBox({ selected: bCurrentStatus, text: "Erledigt" });

            var oDialog = new Dialog({
                title: "Aufgabe bearbeiten",
                content: new VBox({
                    items: [
                        new Label({ text: "Titel:" }), oTitleInput,
                        new Label({ text: "Status:" }), oStatusCheckBox
                    ]
                }),
                beginButton: new Button({
                    text: "Speichern",
                    type: "Emphasized",
                    press: function () {
                        // OData v4: Direct Property-Updates auf dem Kontext senden automatisch einen PATCH-Request
                        oContext.setProperty("Title", oTitleInput.getValue());
                        oContext.setProperty("Completed", oStatusCheckBox.getSelected());

                        MessageToast.show("Aufgabe aktualisiert");
                        oDialog.close();
                    }
                }),
                endButton: new Button({
                    text: "Abbrechen",
                    press: function () { oDialog.close(); }
                }),
                afterClose: function () { oDialog.destroy(); }
            });

            oDialog.setBindingContext(oContext);
            this.getView().addDependent(oDialog);
            oDialog.open();
        },

        onDeleteTodo: function (oEvent) {
            console.log("Detail:onDeleteTodo getriggert!");

            var oItem = oEvent.getSource();
            var oContext = oItem.getBindingContext();
            
            if (!oContext) {
                return;
            }
            console.log("Detail:onDeleteTodo: BindingContext Path:", oContext.getProperty("Id"));

            // OData v4: Direktes Löschen über den Binding-Context der Tabellenzeile
            oContext.delete().then(function () {
                MessageToast.show("Aufgabe erfolgreich gelöscht");
            }).catch(function (oError) {
                MessageToast.show("Fehler beim Löschen: " + oError.message);
            });
        }
    });
});