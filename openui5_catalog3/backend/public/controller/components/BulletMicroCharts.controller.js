sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.BulletMicroCharts", {
        
        onInit: function () {
            console.log("BulletMicroChart component view initialized successfully.");
        },

        onChartPress: function () {
            MessageToast.show("Bullet Micro Chart clicked!");
            this.byId("chartStatusLabel").setText("Status: Chart interaction registered.");
        }

    });
});