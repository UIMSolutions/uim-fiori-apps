sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.LineMicroCharts", {
        
        onInit: function () {
            console.log("LineMicroCharts component view initialized successfully.");
        },

        onChartPress: function () {
            MessageToast.show("Line Micro Chart clicked!");
            this.byId("chartStatusLabel").setText("Status: Chart interaction registered.");
        }

    });
});