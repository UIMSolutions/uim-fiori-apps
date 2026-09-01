sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, MessageToast, MessageBox) {
    "use strict";

    return Controller.extend("sap.fiori.addressmanager.controller.Main", {
        
        onInit: function () {
            // Initialisierung
        },

        // 1. CREATE: Neuen Adresseintrag erstellen
        onCreateAddress: function () {
            console.log("onCreateAddress called");
            var oListBinding = this.byId("addressTable").getBinding("items");

            // Erstellt eine neue Entität im OData v4 Model Context
            var oContext = oListBinding.create({
                "FirstName": "Hans",
                "LastName": "Schmidt",
                "Street": "Marienplatz 1",
                "PostalCode": "80331",
                "City": "München",
                "Country": "Deutschland"
            });

            // Auf Bestätigung vom Server warten
            oContext.created().then(function () {
                MessageToast.show("Adresse erfolgreich erstellt!");
            }).catch(function (oError) {
                MessageBox.error("Fehler beim Erstellen: " + oError.message);
            });
        },

        onSearch: function (oEvent) {
            console.log("onSearch called");

            var sQuery = oEvent.getParameter("query");
            var aFilter = [];
            if (sQuery && sQuery.length > 0) {
                aFilter.push(new Filter("LastName", FilterOperator.Contains, sQuery));
            }
            var oTable = this.byId("addressTable");
            var oBinding = oTable.getBinding("items");
            oBinding.filter(aFilter);
        },

        // 2. UPDATE: Feld in ausgewählter Zeile ändern
        onUpdateAddress: function () {
            console.log("onUpdateAddress called");
            
            var oTable = this.byId("addressTable");
            var oSelectedItem = oTable.getSelectedItem();

            if (!oSelectedItem) {
                MessageToast.show("Bitte wähle zuerst eine Zeile aus!");
                return;
            }

            var oContext = oSelectedItem.getBindingContext();
            // Automatisiertes PATCH-Update an Backend senden
            oContext.setProperty("FirstName", "Max (Geändert)");
            
            MessageToast.show("Änderung gesendet.");
        },

        // 3. DELETE: Ausgewählte Adresse löschen
        onDeleteAddress: function () {
            console.log("onDeleteAddress called");

            var oTable = this.byId("addressTable");
            var oSelectedItem = oTable.getSelectedItem();

            if (!oSelectedItem) {
                MessageToast.show("Bitte wähle zuerst eine Zeile aus!");
                return;
            }

            var oContext = oSelectedItem.getBindingContext();
            oContext.delete().then(function () {
                MessageToast.show("Adresse gelöscht!");
            }).catch(function (oError) {
                MessageBox.error("Fehler beim Löschen: " + oError.message);
            });
        },

        // Refresh-Button zum manuellen Neuladen
        onRefresh: function () {
            this.byId("addressTable").getBinding("items").refresh();
        },

        onOpenCreateDialog: function () {
            console.log("onOpenCreateDialog called");
            var oModel = this.getView().getModel();
            
            // OData v4 Transient Context zum Hinzufügen erstellen
            var oTable = this.byId("addressTable");
            console.log("oTable: ", oTable);

            var oListBinding = oTable.getBinding("items");
            console.log("oListBinding: ", oListBinding);

            var oContext = oListBinding.create({
                "FirstName": "",
                "LastName": "",
                "Street": "",
                "PostalCode": "",
                "City": "",
                "Country": "Deutschland"
            });

            if (!this._oDialog) {
                this._oDialog = new Dialog({
                    title: "Neue Adresse anlegen",
                    content: [
                        new SimpleForm({
                            editable: true,
                            content: [
                                new sap.m.Label({ text: "Vorname" }),
                                new Input({ value: "{FirstName}" }),
                                new sap.m.Label({ text: "Nachname" }),
                                new Input({ value: "{LastName}" }),
                                new sap.m.Label({ text: "Straße" }),
                                new Input({ value: "{Street}" }),
                                new sap.m.Label({ text: "PLZ" }),
                                new Input({ value: "{PostalCode}" }),
                                new sap.m.Label({ text: "Stadt" }),
                                new Input({ value: "{City}" }),
                                new sap.m.Label({ text: "Land" }),
                                new Input({ value: "{Country}" })
                            ]
                        })
                    ],
                    beginButton: new Button({
                        text: "Speichern",
                        type: "Emphasized",
                        press: function () {
                            // Backend-Synchronisation anstoßen ($batch POST via vibe.d)
                            oModel.submitBatch("addressUpdateGroup").then(function () {
                                MessageToast.show("Adresse erfolgreich gespeichert!");
                                this._oDialog.close();
                            }.bind(this));
                        }.bind(this)
                    }),
                    endButton: new Button({
                        text: "Abbrechen",
                        press: function () {
                            oContext.delete(); // Verwirft die transiente Entität
                            this._oDialog.close();
                        }.bind(this)
                    })
                });
                this.getView().addDependent(this._oDialog);
            }

            this._oDialog.setBindingContext(oContext);
            this._oDialog.open();
        }
    });
});