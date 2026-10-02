sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/Popover",
    "sap/m/List",
    "sap/m/StandardListItem",
    "sap/ui/model/json/JSONModel"
], function (Controller, MessageToast, Popover, List, StandardListItem, JSONModel) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.App", {

        onNotificationsPressed: function (oEvent) {
            var oButton = oEvent.getSource(),
                oPopover = this._getNotificationPopover();

            // Toggle statt erneutem Laden, wenn bereits geöffnet
            if (oPopover.isOpen()) {
                oPopover.close();
                return;
            }

            oPopover.getModel().loadData("/odata/v4/Notifications")
                .then(function () {
                    oPopover.openBy(oButton);
                })
                .catch(function () {
                    MessageToast.show("Fehler beim Laden der Benachrichtigungen.");
                });
        },

        _getNotificationPopover: function () {
            if (!this._oNotificationPopover) {
                this._oNotificationPopover = new Popover({
                    title: "Benachrichtigungen",
                    contentWidth: "360px",
                    content: new List({
                        items: {
                            path: "/value",
                            template: new StandardListItem({
                                title: "{title}",
                                description: "{description}",
                                icon: "{icon}",
                                infoState: "{infoState}"
                            })
                        }
                    })
                });
                this._oNotificationPopover.setModel(new JSONModel());
                this.getView().addDependent(this._oNotificationPopover);
            }
            return this._oNotificationPopover;
        },

        onToggleSideNav: function () {
            var oToolPage = this.byId("toolPage");
            oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
        },

        onSideNavSelect: function (oEvent) {
            var sKey = oEvent.getParameter("item").getKey();
            if (sKey) {
                this.getOwnerComponent().getRouter().navTo(sKey);
            }
        },

        onLogout: function () {
            MessageToast.show("Erfolgreich abgemeldet.");
        }

    });
});