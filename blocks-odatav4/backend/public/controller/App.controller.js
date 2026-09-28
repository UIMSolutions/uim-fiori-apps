sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Fragment",
    "sap/ui/core/Configuration",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, Fragment, Configuration, MessageToast, MessageBox) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.App", {

        onInit: function () {
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
            MessageBox.confirm("Möchtest du dich wirklich abmelden?", {
                actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
                onClose: function (sAction) {
                    if (sAction === MessageBox.Action.OK) {
                        // Logout-Logik (z.B. Redirect oder Session clearen)
                        MessageToast.show("Erfolgreich abgemeldet.");
                        window.location.reload();
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

            if (oNavigationList) {
                oNavigationList.setSelectedKey(sRouteName);
            }
        }

    });
});