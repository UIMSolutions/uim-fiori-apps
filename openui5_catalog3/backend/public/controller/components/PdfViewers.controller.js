sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.PdfViewers", {
        
        onInit: function () {
            console.log("PdfViewer component view initialized successfully.");
        },

        onPdfLoaded: function (oEvent) {
            MessageToast.show("PDF document loaded successfully.");
            this.byId("pdfStatusLabel").setText("Status: Document ready and rendered.");
        }

    });
});