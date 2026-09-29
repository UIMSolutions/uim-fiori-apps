sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.LoggingHistory", {
        onInit: function () {
            var oModel = new JSONModel({
                items: [],
                filtered: [],
                filter: {
                    severity: "all",
                    query: "",
                    fromDate: "",
                    toDate: ""
                },
                pagination: {
                    limit: 2,
                    offset: 0,
                    total: 0,
                    hasMore: false,
                    loading: false
                }
            });

            this.getView().setModel(oModel, "logs");
            this._loadLogs({ reset: true, showToast: false });
        },

        onRefresh: function () {
            this._loadLogs({ reset: true, showToast: true });
        },

        onFilterChange: function (oEvent) {
            var sKey = oEvent.getParameter("item").getKey();
            var oModel = this.getView().getModel("logs");
            oModel.setProperty("/filter/severity", sKey);
            this._loadLogs({ reset: true, showToast: false });
        },

        onSearch: function (oEvent) {
            var sValue = oEvent.getParameter("newValue");
            if (typeof sValue !== "string") {
                sValue = oEvent.getParameter("query") || "";
            }

            var oModel = this.getView().getModel("logs");
            oModel.setProperty("/filter/query", sValue.trim().toLowerCase());
            this._loadLogs({ reset: true, showToast: false });
        },

        onDateChange: function () {
            var oModel = this.getView().getModel("logs");
            oModel.setProperty("/filter/fromDate", this.byId("fromDate").getValue() || "");
            oModel.setProperty("/filter/toDate", this.byId("toDate").getValue() || "");
            this._loadLogs({ reset: true, showToast: false });
        },

        onLoadMore: function () {
            this._loadLogs({ reset: false, showToast: false });
        },

        _loadLogs: function (mOptions) {
            var oOptions = mOptions || {};
            var oModel = this.getView().getModel("logs");
            var iOffset = oOptions.reset ? 0 : (oModel.getProperty("/pagination/offset") || 0);
            var sUrl = this._buildLogsApiUrl(iOffset);

            oModel.setProperty("/pagination/loading", true);

            fetch(sUrl)
                .then(function (oResponse) {
                    if (!oResponse.ok) {
                        throw new Error("HTTP " + oResponse.status);
                    }
                    return oResponse.json();
                })
                .then(function (oPayload) {
                    var aExisting = oOptions.reset ? [] : (oModel.getProperty("/items") || []);
                    var aItems = oPayload.items || [];
                    var aMerged = aExisting.concat(aItems);
                    var iTotal = oPayload.total || aMerged.length;
                    var iNewOffset = oOptions.reset ? aItems.length : (iOffset + aItems.length);

                    oModel.setProperty("/items", aMerged);
                    oModel.setProperty("/filtered", aMerged);
                    oModel.setProperty("/pagination/offset", iNewOffset);
                    oModel.setProperty("/pagination/total", iTotal);
                    oModel.setProperty("/pagination/hasMore", iNewOffset < iTotal);

                    if (oOptions.showToast) {
                        MessageToast.show("Historie aktualisiert.");
                    }
                }.bind(this))
                .catch(function () {
                    oModel.setProperty("/items", []);
                    oModel.setProperty("/filtered", []);
                    oModel.setProperty("/pagination/offset", 0);
                    oModel.setProperty("/pagination/total", 0);
                    oModel.setProperty("/pagination/hasMore", false);
                    MessageToast.show("Logs konnten nicht geladen werden.");
                })
                .finally(function () {
                    oModel.setProperty("/pagination/loading", false);
                });
        },

        _buildLogsApiUrl: function (iOffset) {
            var oModel = this.getView().getModel("logs");
            var oFilter = oModel.getProperty("/filter") || {};
            var oPagination = oModel.getProperty("/pagination") || {};
            var oParams = new URLSearchParams();

            if (oFilter.severity && oFilter.severity !== "all") {
                oParams.set("severity", oFilter.severity);
            }
            if (oFilter.query) {
                oParams.set("q", oFilter.query);
            }
            if (oFilter.fromDate) {
                oParams.set("from", oFilter.fromDate);
            }
            if (oFilter.toDate) {
                oParams.set("to", oFilter.toDate);
            }
            oParams.set("limit", String(oPagination.limit || 20));
            oParams.set("offset", String(iOffset || 0));

            var sQuery = oParams.toString();
            return sQuery ? "/api/logs?" + sQuery : "/api/logs";
        }
    });
});
