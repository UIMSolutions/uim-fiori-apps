sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (Controller, MessageBox, MessageToast) {
  "use strict";

  return Controller.extend("admin.client.controller.Main", {
    onInit: function () {
      this._model = this.getView().getModel();
      this.onRefresh();
    },

    _api: function (path, options) {
      return fetch(path, options).then(function (response) {
        if (!response.ok) {
          return response.text().then(function (body) {
            throw new Error(body || ("Request failed: " + response.status));
          });
        }

        if (response.status === 204) {
          return null;
        }

        return response.json();
      });
    },

    onRefresh: function () {
      var that = this;
      this._model.setProperty("/busy", true);

      this._api("/odata/v4/admin/Users")
        .then(function (payload) {
          that._model.setProperty("/users", payload.value || []);
        })
        .catch(function (err) {
          MessageBox.error(err.message);
        })
        .finally(function () {
          that._model.setProperty("/busy", false);
        });
    },

    onCreate: function () {
      this._model.setProperty("/selectedUser", {
        id: "",
        username: "",
        email: "",
        role: "Viewer",
        active: true,
        createdAt: ""
      });
      this._model.setProperty("/isNew", true);
      MessageToast.show("Fill in user details and click Save");
    },

    onSelectUser: function (oEvent) {
      var oContext = oEvent.getParameter("listItem").getBindingContext();
      var oSelected = Object.assign({}, oContext.getObject());

      this._model.setProperty("/selectedUser", oSelected);
      this._model.setProperty("/isNew", false);
    },

    onSave: function () {
      var that = this;
      var user = this._model.getProperty("/selectedUser");
      var isNew = this._model.getProperty("/isNew");

      if (!user.username || !user.email) {
        MessageBox.warning("Username and email are required");
        return;
      }

      var path = "/odata/v4/admin/Users";
      var method = "POST";
      if (!isNew) {
        path += "/" + encodeURIComponent(user.id);
        method = "PUT";
      }

      this._model.setProperty("/busy", true);

      this._api(path, {
        method: method,
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(user)
      })
        .then(function () {
          MessageToast.show("User saved");
          that.onRefresh();
        })
        .catch(function (err) {
          MessageBox.error(err.message);
        })
        .finally(function () {
          that._model.setProperty("/busy", false);
        });
    },

    onDelete: function () {
      var that = this;
      var user = this._model.getProperty("/selectedUser");
      var isNew = this._model.getProperty("/isNew");

      if (isNew || !user.id) {
        MessageBox.information("Select an existing user first");
        return;
      }

      MessageBox.confirm("Delete user '" + user.username + "'?", {
        actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
        onClose: function (action) {
          if (action !== MessageBox.Action.OK) {
            return;
          }

          that._model.setProperty("/busy", true);
          that._api("/odata/v4/admin/Users/" + encodeURIComponent(user.id), {
            method: "DELETE"
          })
            .then(function () {
              MessageToast.show("User deleted");
              that.onCreate();
              that.onRefresh();
            })
            .catch(function (err) {
              MessageBox.error(err.message);
            })
            .finally(function () {
              that._model.setProperty("/busy", false);
            });
        }
      });
    }
  });
});
