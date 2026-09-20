sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.WheelSliders", {
        
        onInit: function () {
            console.log("WheelSlider component view initialized successfully.");
        },

        onSliderLiveChange: function (oEvent) {
            var fValue = oEvent.getParameter("value");
            this.byId("sliderValueDisplay").setNumber(fValue);
            this.byId("sliderStatusLabel").setText("Status: Adjusting value live -> " + fValue);
        },

        onSliderChange: function (oEvent) {
            var fValue = oEvent.getParameter("value");
            MessageToast.show("Slider value finalized: " + fValue);
            this.byId("sliderStatusLabel").setText("Status: Finalized selection at -> " + fValue);
        }

    });
});