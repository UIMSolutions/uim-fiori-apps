sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/viz/ui5/controls/Popover"
], function (Controller, JSONModel, Popover) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.Reporting", {
        onInit: function () {
            var oReportingModel = new JSONModel({
                blockTypeStats: [
                    { type: "Grundbausteine", count: 42 },
                    { type: "Architekturbausteine", count: 31 },
                    { type: "Loesungsbausteine", count: 24 },
                    { type: "Schnittstellen", count: 18 }
                ],
                qualityStats: [
                    { rule: "Pflichtfelder fehlen", hits: 14 },
                    { rule: "Duplikate", hits: 6 },
                    { rule: "Veraltete Version", hits: 9 },
                    { rule: "Ohne Verantwortlich", hits: 11 }
                ]
            });

            this.getView().setModel(oReportingModel, "reporting");
        },

        onAfterRendering: function () {
            var oBlockChart = this.byId("blockTypeChart");
            var oQualityChart = this.byId("qualityChart");

            if (oBlockChart && !this._oBlockPopover) {
                this._oBlockPopover = new Popover({});
                this._oBlockPopover.connect(oBlockChart.getVizUid());
            }

            if (oQualityChart && !this._oQualityPopover) {
                this._oQualityPopover = new Popover({});
                this._oQualityPopover.connect(oQualityChart.getVizUid());
            }
        },

        onExit: function () {
            if (this._oBlockPopover) {
                this._oBlockPopover.destroy();
                this._oBlockPopover = null;
            }

            if (this._oQualityPopover) {
                this._oQualityPopover.destroy();
                this._oQualityPopover = null;
            }
        }
    });
});
