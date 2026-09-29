sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Fragment",
    "sap/ui/core/Configuration",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, Fragment, Configuration, JSONModel, MessageToast, MessageBox) {
    "use strict";

    var AUTH_STORAGE_KEY = "ea.architecture.manager.auth";
    var USER_STORAGE_KEY = "ea.architecture.manager.user";

    return Controller.extend("ea.architecture.manager.controller.App", {

        onInit: function () {
            var oAppStateModel = new JSONModel({
                showShell: true
            });

            this.getView().setModel(oAppStateModel, "appState");

            // Aktuelle Sprache des Systems im ViewModel hinterlegen
            var sCurrentLanguage = Configuration.getLanguage().substring(0, 2);
            var oViewModel = this.getOwnerComponent().getModel("viewModel");
            var oRouter = this.getOwnerComponent().getRouter();

            if (oViewModel) {
                oViewModel.setProperty("/currentLanguage", sCurrentLanguage);
            }

            oRouter.attachRouteMatched(this._onRouteMatched, this);
        },

        onNavHome: function () {
            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.navTo("home");
        },

        onToggleSideNavigation: function () {
            var oToolPage = this.byId("toolPage");
            oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
        },

        onSideNavigationSelect: function (oEvent) {
            var oItem = oEvent.getParameter("item");
            var sRoute = oItem && oItem.getKey();

            if (sRoute) {
                this.getOwnerComponent().getRouter().navTo(sRoute);
            }
        },

        onLanguageChange: function (oEvent) {
            var sSelectedLang = oEvent.getParameter("selectedItem").getKey();
            
            // UI5 Sprache zur Laufzeit umstellen
            Configuration.setLanguage(sSelectedLang);

            var oViewModel = this.getOwnerComponent().getModel("viewModel");
            if (oViewModel) {
                oViewModel.setProperty("/currentLanguage", sSelectedLang);
            }
            
            MessageToast.show("Sprache auf " + (sSelectedLang === "de" ? "Deutsch" : "English") + " geändert.");
        },

        onLanguageToggle: function () {
            var sCurrentLanguage = Configuration.getLanguage().substring(0, 2);
            var sNextLanguage = sCurrentLanguage === "de" ? "en" : "de";

            Configuration.setLanguage(sNextLanguage);

            var oViewModel = this.getOwnerComponent().getModel("viewModel");
            if (oViewModel) {
                oViewModel.setProperty("/currentLanguage", sNextLanguage);
            }

            MessageToast.show("Sprache auf " + (sNextLanguage === "de" ? "Deutsch" : "English") + " geändert.");
        },

        onLogout: function () {
            var oRouter = this.getOwnerComponent().getRouter();

            MessageBox.confirm("Möchtest du dich wirklich abmelden?", {
                actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
                onClose: function (sAction) {
                    if (sAction === MessageBox.Action.OK) {
                        localStorage.removeItem(AUTH_STORAGE_KEY);
                        localStorage.removeItem(USER_STORAGE_KEY);
                        sessionStorage.removeItem(AUTH_STORAGE_KEY);
                        sessionStorage.removeItem(USER_STORAGE_KEY);

                        // Simulierter Logout: zurück auf Login und Verlauf ersetzen.
                        oRouter.navTo("login", {}, true);
                        MessageToast.show("Erfolgreich abgemeldet.");
                    }
                }
            });
        }, 

        onMenuPress: function (oEvent) {
            var oButton = oEvent.getSource();
            var oView = this.getView();

            // Lazy Loading des Popovers
            if (!this._pMenuPopover) {
                this._pMenuPopover = Fragment.load({
                    id: oView.getId(),
                    name: "ea.architecture.manager.view.fragment.MenuPopover",
                    controller: this
                }).then(function (oPopover) {
                    oView.addDependent(oPopover);
                    return oPopover;
                });
            }

            this._pMenuPopover.then(function (oPopover) {
                oPopover.openBy(oButton);
            });
        },

        onNavigateTo: function (sRouteName) {
            return function () {
                var oRouter = this.getOwnerComponent().getRouter();
                oRouter.navTo(sRouteName);
                
                // Popover nach der Auswahl schließen
                if (this._pMenuPopover) {
                    this._pMenuPopover.then(function (oPopover) {
                        oPopover.close();
                    });
                }
            }.bind(this);
        },

        _onRouteMatched: function (oEvent) {
            var sRouteName = oEvent.getParameter("name");
            var oNavigationList = this.byId("navigationList");
            var oAppStateModel = this.getView().getModel("appState");
            var oRouter = this.getOwnerComponent().getRouter();
            var bAuthenticated = this._isAuthenticated();
            var bShowShell = sRouteName !== "login";

            if (!bAuthenticated && sRouteName !== "login") {
                if (oAppStateModel) {
                    oAppStateModel.setProperty("/showShell", false);
                }

                oRouter.navTo("login", {}, true);
                return;
            }

            if (bAuthenticated && sRouteName === "login") {
                oRouter.navTo("home", {}, true);
                return;
            }

            if (oAppStateModel) {
                oAppStateModel.setProperty("/showShell", bShowShell);
            }

            if (oNavigationList) {
                oNavigationList.setSelectedKey(bShowShell ? sRouteName : "");
            }
        },

        _isAuthenticated: function () {
            return localStorage.getItem(AUTH_STORAGE_KEY) === "true" || sessionStorage.getItem(AUTH_STORAGE_KEY) === "true";
        }

    });
});