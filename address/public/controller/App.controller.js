sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("sap.fiori.addressmanager.controller.App", {
        onInit: function () {
            // Fügt die Fiori-Standard-Dichte-Klasse für Touch-/Mausunterstützung hinzu
            this.getView().addStyleClass(
                sap.ui.Device.support.touch ? "sapUiSizeCozy" : "sapUiSizeCompact"
            );
        }
    });
});