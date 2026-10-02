sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/core/Fragment",
	"sap/ui/model/json/JSONModel",
	"sap/ui/model/Filter",
	"sap/ui/model/FilterOperator",
	"sap/ui/model/Sorter",
	"sap/m/MessageBox",
	"sap/m/MessageToast"
], function (Controller, Fragment, JSONModel, Filter, FilterOperator, Sorter, MessageBox, MessageToast) {
	"use strict";

	/**
	 * Base controller for a list with search, sort and create/edit/delete.
	 * Subclasses set: fragmentName, searchField, requiredField, numberFields, defaults, labelField.
	 */
	return Controller.extend("vibe.demo.controller.CrudController", {
		onSort: function () {
			var bDescending = this.byId("sortDir").getPressed();
			this.byId("sortDir").setIcon(bDescending ? "sap-icon://sort-descending" : "sap-icon://sort-ascending");
			this._getBinding().sort(new Sorter(this.byId("sortField").getSelectedKey(), bDescending));
		},

		onSearch: function (oEvent) {
			var sQuery = oEvent.getParameter("query");
			this._getBinding().filter(sQuery ? new Filter(this.searchField, FilterOperator.Contains, sQuery) : []);
		},

		onAdd: function () {
			this._openDialog(null, Object.assign({}, this.defaults));
		},

		onEdit: function (oEvent) {
			var oContext = oEvent.getSource().getBindingContext();
			this._openDialog(oContext, Object.assign({}, oContext.getObject()));
		},

		onDelete: function (oEvent) {
			var oContext = oEvent.getSource().getBindingContext(),
				oBundle = this.getView().getModel("i18n").getResourceBundle();
			MessageBox.confirm(oBundle.getText("deleteConfirm", [oContext.getProperty(this.labelField)]), {
				actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
				emphasizedAction: MessageBox.Action.DELETE,
				onClose: function (sAction) {
					if (sAction === MessageBox.Action.DELETE) {
						oContext.delete().then(function () {
							MessageToast.show(oBundle.getText("deleted"));
						}).catch(this._showError.bind(this));
					}
				}.bind(this)
			});
		},

		onSave: function () {
			var oForm = this._dialog.getModel("form").getData(),
				oBundle = this.getView().getModel("i18n").getResourceBundle(),
				oData = {};

			if (!String(oForm[this.requiredField] || "").trim()) {
				MessageToast.show(oBundle.getText("requiredMissing"));
				return;
			}
			Object.keys(oForm).forEach(function (sKey) {
				if (sKey !== "ID" && !sKey.startsWith("@")) {
					oData[sKey] = this.numberFields.indexOf(sKey) >= 0 ? Number(oForm[sKey] || 0) : oForm[sKey];
				}
			}, this);

			var oPromise = this._context ? this._update(this._context, oData) : this._create(oData);
			oPromise.then(function () {
				MessageToast.show(oBundle.getText("saved"));
				this._dialog.close();
			}.bind(this)).catch(this._showError.bind(this));
		},

		onCancel: function () {
			this._dialog.close();
		},

		onExport: function () {
			this._getRows().then(function (aRows) {
				var aCols = this._getExportColumns(),
					fnCell = function (v) {
						return '"' + String(v == null ? "" : v).replace(/"/g, '""') + '"';
					},
					aLines = [aCols.map(function (c) { return fnCell(c.label); }).join(",")];
				aRows.forEach(function (o) {
					aLines.push(aCols.map(function (c) { return fnCell(o[c.key]); }).join(","));
				}, this);
				var oBlob = new Blob(["\ufeff" + aLines.join("\r\n")], { type: "text/csv;charset=utf-8" }),
					oLink = document.createElement("a");
				oLink.href = URL.createObjectURL(oBlob);
				oLink.download = this.exportName + ".csv";
				document.body.appendChild(oLink);
				oLink.click();
				oLink.remove();
				URL.revokeObjectURL(oLink.href);
			}.bind(this)).catch(this._showError.bind(this));
		},

		onPrint: function () {
			this._getRows().then(function (aRows) {
				var fnEsc = function (v) {
						return String(v == null ? "" : v).replace(/[&<>"]/g, function (c) {
							return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
						});
					},
					oBundle = this.getView().getModel("i18n").getResourceBundle(),
					aCols = this._getExportColumns(),
					sHtml = "<!DOCTYPE html><html><head><meta charset='utf-8'><title>" + fnEsc(this.exportName) + "</title>" +
						"<style>body{font-family:Arial,sans-serif}table{border-collapse:collapse;width:100%}" +
						"th,td{border:1px solid #999;padding:4px 8px;text-align:left;font-size:12px}th{background:#eee}</style></head><body>" +
						"<h2>" + fnEsc(oBundle.getText(this.titleKey)) + "</h2><table><thead><tr>" +
						aCols.map(function (c) { return "<th>" + fnEsc(c.label) + "</th>"; }).join("") +
						"</tr></thead><tbody>" +
						aRows.map(function (o) {
							return "<tr>" + aCols.map(function (c) { return "<td>" + fnEsc(o[c.key]) + "</td>"; }).join("") + "</tr>";
						}, this).join("") + "</tbody></table></body></html>",
					oFrame = document.createElement("iframe");
				oFrame.style.cssText = "position:fixed;width:0;height:0;border:0";
				document.body.appendChild(oFrame);
				oFrame.contentDocument.open();
				oFrame.contentDocument.write(sHtml);
				oFrame.contentDocument.close();
				oFrame.contentWindow.onafterprint = function () { oFrame.remove(); };
				oFrame.contentWindow.focus();
				oFrame.contentWindow.print();
			}.bind(this)).catch(this._showError.bind(this));
		},

		_getExportColumns: function () {
			var oBundle = this.getView().getModel("i18n").getResourceBundle();
			return this.exportColumns.map(function (c) {
				return { key: c[0], label: oBundle.getText(c[1]) };
			});
		},

		// Selected rows if any, otherwise the complete list in the current filter and sort order.
		_getRows: function () {
			var aSelected = this.byId("table").getSelectedContexts(),
				oBundle = this.getView().getModel("i18n").getResourceBundle(),
				pContexts = aSelected.length
					? Promise.resolve(aSelected)
					: this._getBinding().requestContexts(0, Infinity);
			return pContexts.then(function (aContexts) {
				MessageToast.show(oBundle.getText(aSelected.length ? "scopeSelected" : "scopeAll", [aContexts.length]));
				return aContexts.map(function (c) { return c.getObject(); });
			});
		},

		_getBinding: function () {
			return this.byId("table").getBinding("items");
		},

		_create: function (oData) {
			var oBinding = this._getBinding(),
				oCreated = oBinding.create(oData, true);
			return oCreated.created().then(function () {
				oBinding.refresh();
			}, function (oError) {
				oBinding.resetChanges();
				throw oError;
			});
		},

		_update: function (oContext, oData) {
			var aChanges = Object.keys(oData).filter(function (sKey) {
				return oContext.getProperty(sKey) !== oData[sKey];
			}).map(function (sKey) {
				return oContext.setProperty(sKey, oData[sKey]);
			});
			return Promise.all(aChanges).then(function () {
				this._getBinding().refresh();
			}.bind(this));
		},

		_openDialog: function (oContext, oData) {
			var oBundle = this.getView().getModel("i18n").getResourceBundle();
			this._context = oContext;
			if (!this._dialogPromise) {
				this._dialogPromise = Fragment.load({
					id: this.getView().getId(),
					name: this.fragmentName,
					controller: this
				}).then(function (oDialog) {
					this.getView().addDependent(oDialog);
					return oDialog;
				}.bind(this));
			}
			this._dialogPromise.then(function (oDialog) {
				this._dialog = oDialog;
				oDialog.setModel(new JSONModel(oData), "form");
				oDialog.setTitle(oBundle.getText(oContext ? "editTitle" : "createTitle"));
				oDialog.open();
			}.bind(this));
		},

		_showError: function (oError) {
			MessageBox.error(oError && oError.message ? oError.message : String(oError));
		}
	});
});
