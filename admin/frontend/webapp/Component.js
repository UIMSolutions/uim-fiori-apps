sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
  "use strict";

  return UIComponent.extend("admin.client.Component", {
    metadata: {
      manifest: "json"
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);

      var oModel = new JSONModel({
        users: [],
        selectedUser: {
          id: "",
          username: "",
          email: "",
          role: "Viewer",
          active: true,
          createdAt: ""
        },
        isNew: false,
        busy: false
      });

      this.setModel(oModel);
    }
  });
});
