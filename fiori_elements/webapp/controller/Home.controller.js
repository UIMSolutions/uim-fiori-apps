sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
	"use strict";

	return Controller.extend("vibe.demo.controller.Home", {
		onInit: function () {
			this.getView().setModel(new JSONModel({ products: "…", orders: "…", revenue: "…", lowStock: [], recent: [], revenueByStatus: [], stockByCategory: [] }), "stats");
			this.getOwnerComponent().getRouter().getRoute("home").attachPatternMatched(this._load, this);
		},

		_load: function () {
			var oStats = this.getView().getModel("stats");
			var sBase = this.getOwnerComponent().getManifestEntry("/sap.app/dataSources/mainService/uri");
			var get = function (sUrl) {
				return fetch(sBase + sUrl).then(function (r) { return r.json(); });
			};

			Promise.all([
				get("Products?$count=true&$top=0"),
				get("Orders?$count=true&$orderby=OrderDate desc,ID desc"),
				get("Products?$filter=Stock lt 20&$orderby=Stock&$top=5"),
				get("Products?$select=Category,Stock")
			]).then(function (a) {
				var group = function (aRows, sKey, sSum, fnState) {
					var m = {}, max = 0;
					aRows.forEach(function (r) { m[r[sKey]] = (m[r[sKey]] || 0) + r[sSum]; });
					Object.keys(m).forEach(function (k) { max = Math.max(max, m[k]); });
					return Object.keys(m).sort().map(function (k) {
						return { label: k, value: m[k], percent: max ? m[k] / max * 100 : 0, state: fnState(k) };
					});
				};
				var mState = { Open: "Warning", Shipped: "Success", Cancelled: "Error" };
				var aOrders = a[1].value;
				oStats.setData({
					products: a[0]["@odata.count"],
					orders: a[1]["@odata.count"],
					revenue: aOrders.filter(function (o) { return o.Status !== "Cancelled"; })
						.reduce(function (s, o) { return s + o.Total; }, 0).toLocaleString(),
					lowStock: a[2].value,
					recent: aOrders.slice(0, 3),
					revenueByStatus: group(aOrders, "Status", "Total", function (k) { return mState[k] || "None"; }),
					stockByCategory: group(a[3].value, "Category", "Stock", function () { return "Information"; })
				});
			});
		},

		onGo: function (sRoute) {
			this.getOwnerComponent().getRouter().navTo(sRoute);
		}
	});
});
