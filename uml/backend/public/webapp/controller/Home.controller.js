sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageToast"
], function (Controller, MessageToast) {
  "use strict";

  return Controller.extend("uml.controller.Home", {
    onNavWorkspace: function () {
      this.getOwnerComponent().getRouter().navTo("workspace");
    },

    onNavLibrary: function () {
      this.getOwnerComponent().getRouter().navTo("library");
    },

    onNavInsights: function () {
      this.getOwnerComponent().getRouter().navTo("insights");
    },

    onQuickCreate: function () {
      this.getOwnerComponent().getRouter().navTo("workspace");
      MessageToast.show("Opened workspace. Click Create to start a new diagram.");
    }
  });
});
