sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.AreaMicroChart", {
        
        onInit: function () {
            console.log("AreaMicroChart component view initialized successfully.");
        },

        onChartPress: function () {
            MessageToast.show("Area Micro Chart clicked!");
            this.byId("chartStatusLabel").setText("Status: Chart interaction registered.");
        }

    });
});