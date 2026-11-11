sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/Label",
    "sap/m/Input",
    "sap/m/Select",
    "sap/ui/core/Item",
    "sap/m/VBox",
    "sap/m/CheckBox"
], function (Controller, JSONModel, MessageToast, MessageBox, Dialog, Button, Label, Input, Select, Item, VBox, CheckBox) {
    "use strict";

    var USER_STORAGE_KEY = "ea.architecture.manager.user";

    return Controller.extend("ea.architecture.manager.controller.UserManagement", {
        onInit: function () {
            var oCurrentUser = this._getCurrentUser();
            var bCanManageUsers = oCurrentUser.role === "Administrator";

            var oViewModel = new JSONModel({
                canManageUsers: bCanManageUsers,
                currentRole: oCurrentUser.role
            });

            this.getView().setModel(oViewModel, "vm");
        },

        onAddUser: function () {
            if (!this._canManageUsers()) {
                this._showNotAuthorized();
                return;
            }

            this._openUserDialog({
                title: "Benutzer anlegen",
                confirmText: "Anlegen",
                user: {
                    Username: "",
                    Email: "",
                    Role: "Viewer",
                    Active: true
                },
                onConfirm: function (oValues) {
                    var oTable = this.byId("userTable");
                    var oListBinding = oTable.getBinding("items");
                    var oContext = oListBinding.create(oValues);

                    oContext.created().then(function () {
                        MessageToast.show("Benutzer wurde angelegt.");
                    }).catch(function () {
                        MessageBox.error("Benutzer konnte nicht angelegt werden.");
                    });
                }.bind(this)
            });
        },

        onRefreshUsers: function () {
            var oBinding = this.byId("userTable").getBinding("items");
            if (oBinding) {
                oBinding.refresh();
                MessageToast.show("Benutzerliste aktualisiert.");
            }
        },

        onEditSelectedUser: function () {
            if (!this._canManageUsers()) {
                this._showNotAuthorized();
                return;
            }

            var oContext = this._getSelectedUserContext();
            if (!oContext) {
                MessageToast.show("Bitte zuerst einen Benutzer auswaehlen.");
                return;
            }

            var oUser = oContext.getObject();
            this._openUserDialog({
                title: "Benutzer bearbeiten",
                confirmText: "Speichern",
                user: {
                    Username: oUser.Username,
                    Email: oUser.Email,
                    Role: oUser.Role,
                    Active: !!oUser.Active
                },
                onConfirm: function (oValues) {
                    oContext.setProperty("Username", oValues.Username);
                    oContext.setProperty("Email", oValues.Email);
                    oContext.setProperty("Role", oValues.Role);
                    oContext.setProperty("Active", oValues.Active);
                    MessageToast.show("Benutzer wurde aktualisiert.");
                }
            });
        },

        onDeactivateSelectedUser: function () {
            if (!this._canManageUsers()) {
                this._showNotAuthorized();
                return;
            }

            var oContext = this._getSelectedUserContext();
            if (!oContext) {
                MessageToast.show("Bitte zuerst einen Benutzer auswaehlen.");
                return;
            }

            oContext.setProperty("Active", false);
            MessageToast.show("Benutzer deaktiviert.");
        },

        _getSelectedUserContext: function () {
            var oTable = this.byId("userTable");
            var oItem = oTable.getSelectedItem();
            return oItem ? oItem.getBindingContext() : null;
        },

        _canManageUsers: function () {
            return !!this.getView().getModel("vm").getProperty("/canManageUsers");
        },

        _showNotAuthorized: function () {
            MessageBox.warning("Keine Berechtigung: Diese Aktion ist nur fuer Administratoren verfuegbar.");
        },

        _getCurrentUser: function () {
            var sRaw = localStorage.getItem(USER_STORAGE_KEY) || sessionStorage.getItem(USER_STORAGE_KEY) || "";
            if (!sRaw) {
                return { username: "", role: "Viewer" };
            }

            try {
                var oUser = JSON.parse(sRaw);
                return {
                    username: oUser.username || "",
                    role: oUser.role || "Viewer"
                };
            } catch (e) {
                return {
                    username: sRaw,
                    role: "Viewer"
                };
            }
        },

        _openUserDialog: function (mConfig) {
            var oUsernameInput = new Input({ value: mConfig.user.Username, required: true });
            var oEmailInput = new Input({ value: mConfig.user.Email, type: "Email", required: true });
            var oRoleSelect = new Select({
                selectedKey: mConfig.user.Role,
                items: [
                    new Item({ key: "Administrator", text: "Administrator" }),
                    new Item({ key: "Editor", text: "Editor" }),
                    new Item({ key: "Viewer", text: "Viewer" })
                ]
            });
            var oActiveCheck = new CheckBox({ text: "Aktiv", selected: !!mConfig.user.Active });

            var oDialog = new Dialog({
                title: mConfig.title,
                contentWidth: "30rem",
                content: new VBox({
                    class: "sapUiMediumMargin",
                    items: [
                        new Label({ text: "Benutzername", labelFor: oUsernameInput }),
                        oUsernameInput,
                        new Label({ text: "E-Mail", labelFor: oEmailInput, class: "sapUiSmallMarginTop" }),
                        oEmailInput,
                        new Label({ text: "Rolle", labelFor: oRoleSelect, class: "sapUiSmallMarginTop" }),
                        oRoleSelect,
                        oActiveCheck
                    ]
                }),
                beginButton: new Button({
                    text: mConfig.confirmText,
                    type: "Emphasized",
                    press: function () {
                        var sUsername = oUsernameInput.getValue().trim();
                        var sEmail = oEmailInput.getValue().trim();

                        if (!sUsername || !sEmail) {
                            MessageBox.warning("Benutzername und E-Mail sind Pflichtfelder.");
                            return;
                        }

                        mConfig.onConfirm({
                            Username: sUsername,
                            Email: sEmail,
                            Role: oRoleSelect.getSelectedKey(),
                            Active: oActiveCheck.getSelected()
                        });

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
