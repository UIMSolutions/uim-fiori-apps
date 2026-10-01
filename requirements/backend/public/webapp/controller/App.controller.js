sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/json/JSONModel",
  "sap/m/MessageToast",
  "sap/m/MessageBox",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/TextArea",
  "sap/m/Select",
  "sap/ui/core/Item",
  "sap/ui/layout/form/SimpleForm",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (
  Controller,
  JSONModel,
  MessageToast,
  MessageBox,
  Dialog,
  Button,
  Label,
  Input,
  TextArea,
  Select,
  Item,
  SimpleForm,
  Filter,
  FilterOperator
) {
  "use strict";

  return Controller.extend("requirements.controller.App", {
    onInit: function () {
      this._searchText = "";

      var oVM = new JSONModel({
        mode: "create",
        id: "",
        title: "",
        description: "",
        category: "General",
        type: "Business",
        projectId: "",
        parentBusinessRequirementID: "",
        parentSolutionRequirementID: ""
      });

      this.getView().setModel(oVM, "vm");
      this.byId("projectFilter").bindItems({
        path: "/Projects",
        template: new Item({
          key: "{ID}",
          text: "{Name} ({ID})"
        })
      });
    },

    onSearch: function (oEvent) {
      this._searchText = oEvent.getParameter("newValue") || "";
      this._applyFilters(this._searchText, this.byId("projectFilter").getSelectedKey());
    },

    onProjectFilterChange: function (oEvent) {
      this._applyFilters(this._searchText, oEvent.getSource().getSelectedKey());
    },

    _applyFilters: function (sSearch, sProjectID) {
      var aFilters = [];
      if (sProjectID) {
        aFilters.push(new Filter("ProjectID", FilterOperator.EQ, sProjectID));
      }

      if (sSearch) {
        aFilters.push(new Filter({
          filters: [
            new Filter("Title", FilterOperator.Contains, sSearch),
            new Filter("Category", FilterOperator.Contains, sSearch),
            new Filter("Type", FilterOperator.Contains, sSearch)
          ],
          and: false
        }));
      }

      this.byId("requirementsTable").getBinding("items").filter(aFilters);
    },

    onCreate: function () {
      var oVM = this.getView().getModel("vm");
      oVM.setData({
        mode: "create",
        id: "",
        title: "",
        description: "",
        category: "General",
        type: "Business",
        projectId: "",
        parentBusinessRequirementID: "",
        parentSolutionRequirementID: ""
      });
      this._openEditDialog("Create Requirement");
    },

    onEdit: function () {
      var oContext = this._getSelectedContext();
      if (!oContext) {
        MessageToast.show("Select one requirement first");
        return;
      }

      var oData = oContext.getObject();
      this.getView().getModel("vm").setData({
        mode: "edit",
        id: oData.ID,
        title: oData.Title,
        description: oData.Description,
        category: oData.Category,
        type: oData.Type,
        projectId: oData.ProjectID,
        parentBusinessRequirementID: oData.ParentBusinessRequirementID,
        parentSolutionRequirementID: oData.ParentSolutionRequirementID
      });
      this._openEditDialog("Edit Requirement");
    },

    onCategorize: function () {
      var oContext = this._getSelectedContext();
      if (!oContext) {
        MessageToast.show("Select one requirement first");
        return;
      }

      var oDialog = new Dialog({
        title: "Categorize Requirement",
        contentWidth: "28rem",
        content: [
          new Label({ text: "Category" }),
          new Input("categoryInput", {
            value: oContext.getObject().Category,
            width: "100%",
            placeholder: "e.g. Security, UX, Compliance"
          })
        ],
        beginButton: new Button({
          text: "Save",
          type: "Emphasized",
          press: function () {
            var sCategory = sap.ui.getCore().byId("categoryInput").getValue().trim() || "General";
            oContext.setProperty("Category", sCategory);
            oContext.setProperty("UpdatedAt", new Date().toISOString());
            this.getView().getModel().submitBatch("$auto").then(function () {
              MessageToast.show("Category updated");
            });
            oDialog.close();
          }.bind(this)
        }),
        endButton: new Button({
          text: "Cancel",
          press: function () {
            oDialog.close();
          }
        }),
        afterClose: function () {
          oDialog.destroy();
        }
      });

      oDialog.open();
    },

    onDelete: function () {
      var oContext = this._getSelectedContext();
      if (!oContext) {
        MessageToast.show("Select one requirement first");
        return;
      }

      MessageBox.confirm("Delete requirement " + oContext.getObject().ID + "?", {
        emphasizedAction: MessageBox.Action.DELETE,
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.DELETE) {
            return;
          }

          oContext.delete("$auto").then(function () {
            MessageToast.show("Requirement deleted");
          }).catch(function (oErr) {
            MessageBox.error("Delete failed: " + (oErr.message || "Unknown error"));
          });
        }
      });
    },

    onExport: function () {
      var aRows = this.byId("requirementsTable").getItems().map(function (oItem) {
        return oItem.getBindingContext().getObject();
      });

      if (!aRows.length) {
        MessageToast.show("No requirements available for export");
        return;
      }

      var aHeader = [
        "ID",
        "Title",
        "Description",
        "Category",
        "Type",
        "ProjectID",
        "ParentBusinessRequirementID",
        "ParentSolutionRequirementID",
        "CreatedAt",
        "UpdatedAt"
      ];

      var aLines = [aHeader.join(",")];
      aRows.forEach(function (oRow) {
        var aLine = aHeader.map(function (sField) {
          return this._toCsvCell(oRow[sField]);
        }.bind(this));
        aLines.push(aLine.join(","));
      }.bind(this));

      var sCsv = aLines.join("\n");
      var oBlob = new Blob([sCsv], { type: "text/csv;charset=utf-8" });
      var sUrl = URL.createObjectURL(oBlob);
      var oLink = document.createElement("a");
      oLink.href = sUrl;
      oLink.download = "requirements-export.csv";
      document.body.appendChild(oLink);
      oLink.click();
      document.body.removeChild(oLink);
      URL.revokeObjectURL(sUrl);

      MessageToast.show("CSV exported");
    },

    onPrint: function () {
      window.print();
    },

    _openEditDialog: function (sTitle) {
      var oVM = this.getView().getModel("vm");

      var oDialog = new Dialog({
        title: sTitle,
        contentWidth: "42rem",
        contentHeight: "34rem",
        verticalScrolling: true,
        content: [
          new SimpleForm({
            editable: true,
            layout: "ResponsiveGridLayout",
            labelSpanL: 3,
            labelSpanM: 3,
            columnsL: 1,
            columnsM: 1,
            content: [
              new Label({ text: "ID" }),
              new Input({ value: "{vm>/id}", editable: "{= ${vm>/mode} === 'create' }" }),

              new Label({ text: "Title" }),
              new Input({ value: "{vm>/title}" }),

              new Label({ text: "Description" }),
              new TextArea({ value: "{vm>/description}", rows: 4, maxLength: 5000 }),

              new Label({ text: "Category" }),
              new Input({ value: "{vm>/category}" }),

              new Label({ text: "Type" }),
              new Select({
                selectedKey: "{vm>/type}",
                items: [
                  new Item({ key: "Business", text: "Business" }),
                  new Item({ key: "Solution", text: "Solution" })
                ]
              }),

              new Label({ text: "Project" }),
              new Select({
                selectedKey: "{vm>/projectId}",
                items: {
                  path: "/Projects",
                  template: new Item({ key: "{ID}", text: "{Name} ({ID})" })
                }
              }),

              new Label({ text: "Parent Business Requirement ID" }),
              new Input({ value: "{vm>/parentBusinessRequirementID}" }),

              new Label({ text: "Parent Solution Requirement ID" }),
              new Input({ value: "{vm>/parentSolutionRequirementID}" })
            ]
          })
        ],
        beginButton: new Button({
          text: "Save",
          type: "Emphasized",
          press: function () {
            this._saveDialogData(oDialog);
          }.bind(this)
        }),
        endButton: new Button({
          text: "Cancel",
          press: function () {
            oDialog.close();
          }
        }),
        afterClose: function () {
          oDialog.destroy();
        }
      });

      oDialog.setModel(oVM, "vm");
      oDialog.setModel(this.getView().getModel());
      oDialog.open();
    },

    _saveDialogData: function (oDialog) {
      var oVM = this.getView().getModel("vm");
      var oData = oVM.getData();
      var oModel = this.getView().getModel();

      if (!oData.title || !oData.projectId) {
        MessageBox.error("Title and Project are required");
        return;
      }

      var oPayload = {
        ID: oData.id,
        Title: oData.title,
        Description: oData.description,
        Category: oData.category || "General",
        Type: oData.type,
        ProjectID: oData.projectId,
        ParentBusinessRequirementID: oData.parentBusinessRequirementID,
        ParentSolutionRequirementID: oData.parentSolutionRequirementID
      };

      if (oPayload.Type === "Business") {
        oPayload.ParentBusinessRequirementID = "";
        oPayload.ParentSolutionRequirementID = "";
      }

      if (oData.mode === "create") {
        var oListBinding = oModel.bindList("/Requirements");
        var oContext = oListBinding.create(oPayload);
        oContext.created().then(function () {
          MessageToast.show("Requirement created");
          oDialog.close();
        }).catch(function (oErr) {
          MessageBox.error("Create failed: " + (oErr.message || "Unknown error"));
        });
        return;
      }

      var oContextToUpdate = this._getSelectedContext();
      if (!oContextToUpdate) {
        MessageBox.error("No requirement selected for update");
        return;
      }

      Object.keys(oPayload).forEach(function (sField) {
        oContextToUpdate.setProperty(sField, oPayload[sField]);
      });
      oContextToUpdate.setProperty("UpdatedAt", new Date().toISOString());

      oModel.submitBatch("$auto").then(function () {
        MessageToast.show("Requirement updated");
        oDialog.close();
      }).catch(function (oErr) {
        MessageBox.error("Update failed: " + (oErr.message || "Unknown error"));
      });
    },

    _getSelectedContext: function () {
      var oTable = this.byId("requirementsTable");
      var oItem = oTable.getSelectedItem();
      return oItem ? oItem.getBindingContext() : null;
    },

    _toCsvCell: function (vValue) {
      var sValue = vValue == null ? "" : String(vValue);
      return '"' + sValue.replace(/"/g, '""') + '"';
    }
  });
});
