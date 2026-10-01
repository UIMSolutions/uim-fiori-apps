sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
  "use strict";

  return Controller.extend("requirements.controller.Home", {
    onNavProjects: function () {
      this.getOwnerComponent().getRouter().navTo("projects");
    },

    onNavBusiness: function () {
      this.getOwnerComponent().getRouter().navTo("business");
    },

    onNavSolution: function () {
      this.getOwnerComponent().getRouter().navTo("solution");
    }
  });
});
