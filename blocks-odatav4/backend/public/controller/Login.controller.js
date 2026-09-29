sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, MessageToast, MessageBox) {
    "use strict";

    var AUTH_STORAGE_KEY = "ea.architecture.manager.auth";
    var USER_STORAGE_KEY = "ea.architecture.manager.user";

    return Controller.extend("ea.architecture.manager.controller.Login", {
        onAfterRendering: function () {
            var sStoredRaw = localStorage.getItem(USER_STORAGE_KEY) || sessionStorage.getItem(USER_STORAGE_KEY) || "";
            var sStoredUser = "";
            var bPersistentAuth = localStorage.getItem(AUTH_STORAGE_KEY) === "true";

            if (sStoredRaw) {
                try {
                    var oStored = JSON.parse(sStoredRaw);
                    sStoredUser = oStored.username || "";
                } catch (e) {
                    // Backward compatibility for older plain-string storage.
                    sStoredUser = sStoredRaw;
                }
            }

            if (sStoredUser) {
                this.byId("loginUsername").setValue(sStoredUser);
            }

            this.byId("loginRememberMe").setSelected(bPersistentAuth);
        },

        onLoginPress: async function (oEvent) {
            var oView = this.getView();
            var oUserInput = oView.byId("loginUsername");
            var oPasswordInput = oView.byId("loginPassword");
            var oRememberMe = oView.byId("loginRememberMe");
            var oLoginButton = oView.byId("loginButton");
            var sUser = oUserInput.getValue().trim();
            var sPassword = oPasswordInput.getValue();
            var bRememberMe = oRememberMe.getSelected();

            oUserInput.setValueState("None");
            oPasswordInput.setValueState("None");

            if (!sUser) {
                oUserInput.setValueState("Error");
                oUserInput.setValueStateText("Bitte Benutzernamen eingeben.");
            }

            if (!sPassword) {
                oPasswordInput.setValueState("Error");
                oPasswordInput.setValueStateText("Bitte Passwort eingeben.");
            }

            if (!sUser || !sPassword) {
                return;
            }

            if (oLoginButton) {
                oLoginButton.setEnabled(false);
                oLoginButton.setBusy(true);
            }

            try {
                var oResponse = await fetch("/api/auth/login", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        username: sUser,
                        password: sPassword
                    })
                });

                var oPayload = await oResponse.json().catch(function () {
                    return {};
                });

                if (!oResponse.ok || !oPayload.authenticated) {
                    oPasswordInput.setValueState("Error");
                    oPasswordInput.setValueStateText("Benutzername oder Passwort ungültig.");
                    MessageBox.error(oPayload.message || "Anmeldung fehlgeschlagen.");
                    return;
                }

                if (bRememberMe) {
                    localStorage.setItem(AUTH_STORAGE_KEY, "true");
                    localStorage.setItem(USER_STORAGE_KEY, JSON.stringify({
                        username: sUser,
                        role: oPayload.role || "Viewer"
                    }));
                    sessionStorage.removeItem(AUTH_STORAGE_KEY);
                    sessionStorage.removeItem(USER_STORAGE_KEY);
                } else {
                    sessionStorage.setItem(AUTH_STORAGE_KEY, "true");
                    sessionStorage.setItem(USER_STORAGE_KEY, JSON.stringify({
                        username: sUser,
                        role: oPayload.role || "Viewer"
                    }));
                    localStorage.removeItem(AUTH_STORAGE_KEY);
                    localStorage.removeItem(USER_STORAGE_KEY);
                }

                MessageToast.show("Anmeldung erfolgreich");
                this.getOwnerComponent().getRouter().navTo("home", {}, true);
            } catch (oError) {
                MessageBox.error("Der Anmeldeservice ist derzeit nicht erreichbar.");
            } finally {
                if (oLoginButton) {
                    oLoginButton.setBusy(false);
                    oLoginButton.setEnabled(true);
                }
            }
        },

        onSubmitLogin: function () {
            this.onLoginPress();
        }
    });
});
