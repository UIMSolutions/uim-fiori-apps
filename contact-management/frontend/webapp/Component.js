sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("contact.manager.Component", {
        metadata: {
            manifest: "json"
        },

        init: function () {
            // 1. Rufen Sie die init-Funktion der Basisklasse auf
            // Dies liest die manifest.json und erstellt das Routing-Objekt
            UIComponent.prototype.init.apply(this, arguments);

            // 2. Initiales Datenmodell für die Anwendung setzen (falls noch nicht aus manifest geladen)
            var oModel = new JSONModel();
            this.setModel(oModel);

            // 3. Router nach der Basis-Initialisierung starten
            var oRouter = this.getRouter();
            if (oRouter) {
                oRouter.initialize();
            } else {
                console.error("Router konnte nicht initialisiert werden. Bitte Prüfen Sie die 'routing'-Sektion in der manifest.json.");
            }
        }
    });
});