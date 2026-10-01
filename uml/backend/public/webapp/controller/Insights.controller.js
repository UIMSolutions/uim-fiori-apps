sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
  "use strict";

  return Controller.extend("uml.controller.Insights", {
    onInit: function () {
      var oModel = new JSONModel({
        totals: {
          diagrams: 0,
          projects: 0,
          lastUpdated: "-"
        },
        projects: []
      });

      this.getView().setModel(oModel, "insights");
      this._loadInsights();
    },

    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavWorkspace: function () {
      this.getOwnerComponent().getRouter().navTo("workspace");
    },

    onNavLibrary: function () {
      this.getOwnerComponent().getRouter().navTo("library");
    },

    onRefresh: function () {
      this._loadInsights();
    },

    _loadInsights: function () {
      var oDataModel = this.getOwnerComponent().getModel();
      var oInsightsModel = this.getView().getModel("insights");

      Promise.all([
        oDataModel.bindList("/Diagrams").requestContexts(),
        oDataModel.bindList("/Projects").requestContexts(),
        oDataModel.bindList("/DashboardStats").requestContexts()
      ]).then(function (aResults) {
        var aDiagramCtx = aResults[0];
        var aProjectCtx = aResults[1];
        var aStatsCtx = aResults[2];

        var aProjects = aProjectCtx.map(function (oCtx) {
          return oCtx.getObject();
        });

        var oStats = aStatsCtx.length > 0 ? aStatsCtx[0].getObject() : null;

        oInsightsModel.setData({
          totals: {
            diagrams: aDiagramCtx.length,
            projects: aProjects.length,
            lastUpdated: oStats ? oStats.LastUpdated : "-"
          },
          projects: aProjects
        });
      }).catch(function () {
        oInsightsModel.setData({
          totals: {
            diagrams: 0,
            projects: 0,
            lastUpdated: "-"
          },
          projects: []
        });
      });
    }
  });
});
