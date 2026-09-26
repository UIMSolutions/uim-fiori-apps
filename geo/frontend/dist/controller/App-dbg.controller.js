sap.ui.define([
  "sap/ui/core/mvc/Controller", "sap/ui/model/json/JSONModel", "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
  "use strict";
  return Controller.extend("geo.fiori.controller.App", {
    onInit: function () {
      this.getView().setModel(new JSONModel({ busy: true, message: "" }), "view");
      this.getOwnerComponent().getModel().getMetaModel().requestObject("/")
        .then(() => this.getView().getModel("view").setProperty("/busy", false))
        .catch(() => {
          const view = this.getView().getModel("view");
          view.setProperty("/busy", false);
          view.setProperty("/message", "OData-V4-Metadaten konnten nicht geladen werden.");
        });
    },
    toPosition: function (longitude, latitude) {
      return longitude + ";" + latitude + ";0";
    },
    onSpotPress: function (event) {
      MessageToast.show(event.getSource().getText());
    }
  });
});