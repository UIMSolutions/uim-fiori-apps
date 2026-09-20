sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.ExpandableTexts", {
        
        onInit: function () {
            console.log("ExpandableText component view initialized successfully.");
        },

        onOverflowPressed: function (oEvent) {
            var bExpanded = oEvent.getParameter("expanded");
            var sState = bExpanded ? "Expanded (Showing full text)" : "Collapsed (Showing truncated text)";
            
            MessageToast.show("Text view toggled.");
            this.byId("expandableStatusLabel").setText("Status: " + sState);
        }

    });
});