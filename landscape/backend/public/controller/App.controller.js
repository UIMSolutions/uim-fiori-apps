sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "landscape/frontend/model/formatter"
], function (Controller, MessageToast, formatter) {
    "use strict";
    return Controller.extend("landscape.frontend.controller.App", {
        formatter: formatter,
        onInit: function () {
            console.log("Initializing App controller...");

            this._loadInitialData();
        },
        _loadInitialData: function () {
            console.log("Loading initial data...");

            console.log("Refreshing table bindings...");
            // this.byId("matrixTable").getBinding("items").refresh();
            // this.byId("systemsTable").getBinding("items").refresh();
            // this.byId("kpiCloud").getBinding("items").refresh();
        },
        onApplyFilters: function () {
            console.log("Applying filters...");

            var criticality = this.byId("criticalitySelect").getSelectedKey();
            var operatingModel = this.byId("operatingModelSelect").getSelectedKey();
            var lifecycle = this.byId("lifecycleSelect").getSelectedKey();
            var search = this.byId("nameSearch").getValue();
            var filterParts = [];
            if (criticality) {
                filterParts.push("Criticality eq '" + criticality + "'");
            }
            if (operatingModel) {
                filterParts.push("OperatingModel eq '" + operatingModel + "'");
            }
            if (lifecycle) {
                filterParts.push("LifecycleStatus eq '" + lifecycle + "'");
            }
            if (search) {
                filterParts.push("contains(Name,'" + search + "')");
            }
            var systemsBinding = this.byId("systemsTable").getBinding("items");
            var path = "/Systems";
            if (filterParts.length > 0) {
                path += "?$filter=" + encodeURIComponent(filterParts.join(" and "));
            }
            systemsBinding.changeParameters({
                "$filter": filterParts.length > 0 ? filterParts.join(" and ") : undefined
            });
            systemsBinding.refresh();
            MessageToast.show("Filter aktualisiert");
        },
        onOpenSystemDetail: async function (oEvent) {
            console.log("Opening system detail...");

            var system = oEvent.getSource().getBindingContext().getObject();
            var detailModel = this.getOwnerComponent().getModel("detail");
            detailModel.setProperty("/selectedSystem", system);
            var response = await fetch("/odata/v4/landscape-service/Interfaces?systemId=" + encodeURIComponent(system.ID));
            var payload = await response.json();
            var links = payload.value || [];
            detailModel.setProperty("/interfaces", links);
            var graph = this._buildGraph(system, links);
            detailModel.setProperty("/graphNodes", graph.nodes);
            detailModel.setProperty("/graphLines", graph.lines);
            this.byId("navContainer").to(this.byId("detailPage"));
        },
        _buildGraph: function (system, links) {
            console.log("Building graph for system:", system);

            var nodeMap = {};
            nodeMap[system.ID] = {
                key: system.ID,
                title: system.Name,
                status: "Success"
            };
            var lines = [];
            links.forEach(function (link) {
                var source = link.SourceSystemID;
                var target = link.TargetSystemID;
                if (!nodeMap[source]) {
                    nodeMap[source] = { key: source, title: source, status: "Standard" };
                }
                if (!nodeMap[target]) {
                    nodeMap[target] = { key: target, title: target, status: "Standard" };
                }
                lines.push({
                    from: source,
                    to: target,
                    title: link.Protocol + " / " + link.Classification
                });
            });
            return {
                nodes: Object.keys(nodeMap).map(function (k) { return nodeMap[k]; }),
                lines: lines
            };
        },
        onBackToOverview: function () {
            console.log("Navigating back to overview...");

            this.byId("navContainer").back();
        }
    });
});
