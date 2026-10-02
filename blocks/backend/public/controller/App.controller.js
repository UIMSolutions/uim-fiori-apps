sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/Popover",
    "sap/m/List",
    "sap/m/StandardListItem",
    "sap/m/PlacementType",
    "sap/ui/model/json/JSONModel"
], function (Controller, MessageToast, Popover, List, StandardListItem, PlacementType, JSONModel) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.App", {

        onNotificationsPressed: function (oEvent) {
            var oButton = oEvent.getSource();

            // Lazy Loading des Popovers
            if (!this._oNotificationPopover) {
                // Template für ListItems aus dem Backend
                var oItemTemplate = new StandardListItem({
                    title: "{title}",
                    description: "{description}",
                    icon: "{icon}",
                    infoState: "{infoState}"
                });

                this._oNotificationPopover = new Popover({
                    title: "Benachrichtigungen",
                    contentWidth: "360px",
                    placement: "Start",
                    content: new List({
                        id: "notificationList",
                        items: {
                            path: "/value",
                            template: oItemTemplate
                        }
                    })
                });

                // Eigenes JSONModel für den Popover-Content
                var oNotificationModel = new JSONModel();
                this._oNotificationPopover.setModel(oNotificationModel);
            }

            // Benachrichtigungen live aus dem vibe.d Backend abrufen
            var oModel = this._oNotificationPopover.getModel();
            oModel.loadData("/odata/v4/Notifications")
                .then(function () {
                    // Popover öffnen, sobald Daten geladen sind
                    this._oNotificationPopover.openBy(oButton);
                }.bind(this))
                .catch(function (oError) {
                    MessageToast.show("Fehler beim Laden der Benachrichtigungen.");
                });
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