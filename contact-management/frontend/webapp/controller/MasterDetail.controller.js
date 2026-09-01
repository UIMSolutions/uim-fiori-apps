sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, JSONModel, MessageToast, MessageBox) {
    "use strict";

    return Controller.extend("contact.manager.controller.MasterDetail", {
        onInit: function () {
            // 1. Hauptdatenmodell für den View sicherstellen
            var oModel = new JSONModel({ Contacts: [] });
            this.getView().setModel(oModel);

            // 2. UI-Steuerungsmodell initialisieren
            var oViewModel = new JSONModel({
                editMode: false,
                isNew: false
            });
            this.getView().setModel(oViewModel, "ui");

            // 3. Kontakte vom vibe.d Backend abrufen
            this._loadContacts();
        },

        _loadContacts: function () {
            var oController = this;
            
            jQuery.ajax({
                url: "/api/v1/Contacts",
                method: "GET",
                dataType: "json",
                success: function (data) {
                    // Greife direkt auf das Modell des Views zu
                    var oModel = oController.getView().getModel();
                    if (oModel) {
                        oModel.setData({ Contacts: data });
                    }
                },
                error: function () {
                    MessageToast.show("Fehler beim Laden der Kontakte vom Backend.");
                }
            });
        },

        onSelectContact: function (oEvent) {
            var oItem = oEvent.getParameter("listItem");
            var oContext = oItem.getBindingContext();
            
            var oDetailPage = this.byId("detailPage");
            oDetailPage.setBindingContext(oContext);
            
            this.getView().getModel("ui").setProperty("/editMode", false);
        },

        onAddContact: function () {
            var oModel = this.getView().getModel();
            var aContacts = oModel.getProperty("/Contacts") || [];
            
            var oNewContact = {
                id: "",
                firstName: "Neuer",
                lastName: "Kontakt",
                email: "",
                phone: "",
                company: "",
                address: { street: "", zipCode: "", city: "", country: "" }
            };

            aContacts.push(oNewContact);
            oModel.setProperty("/Contacts", aContacts);

            var iIndex = aContacts.length - 1;
            var oList = this.byId("contactList");
            var oNewItem = oList.getItems()[iIndex];
            
            if (oNewItem) {
                oList.setSelectedItem(oNewItem);
                this.byId("detailPage").setBindingContext(oNewItem.getBindingContext());
            }

            var oUIModel = this.getView().getModel("ui");
            oUIModel.setProperty("/editMode", true);
            oUIModel.setProperty("/isNew", true);
        },

        onEditContact: function () {
            this.getView().getModel("ui").setProperty("/editMode", true);
        },

        onSaveContact: function () {
            var oController = this;
            var oContext = this.byId("detailPage").getBindingContext();
            var oData = oContext.getObject();
            var bIsNew = this.getView().getModel("ui").getProperty("/isNew");

            var sUrl = bIsNew ? "/api/v1/Contacts" : "/api/v1/Contacts/" + oData.id;
            var sMethod = bIsNew ? "POST" : "PUT";

            jQuery.ajax({
                url: sUrl,
                method: sMethod,
                contentType: "application/json",
                data: JSON.stringify(oData),
                success: function () {
                    MessageToast.show("Kontakt erfolgreich gespeichert.");
                    oController.getView().getModel("ui").setProperty("/editMode", false);
                    oController.getView().getModel("ui").setProperty("/isNew", false);
                    oController._loadContacts();
                },
                error: function () {
                    MessageBox.error("Fehler beim Speichern des Kontakts.");
                }
            });
        },

        onDeleteContact: function () {
            var oController = this;
            var oContext = this.byId("detailPage").getBindingContext();
            if (!oContext) return;

            var sId = oContext.getProperty("id");

            MessageBox.confirm("Möchtest du diesen Kontakt wirklich löschen?", {
                onClose: function (sAction) {
                    if (sAction === MessageBox.Action.OK) {
                        jQuery.ajax({
                            url: "/api/v1/Contacts/" + sId,
                            method: "DELETE",
                            success: function () {
                                MessageToast.show("Kontakt gelöscht.");
                                oController._loadContacts();
                            }
                        });
                    }
                }
            });
        }
    });
});