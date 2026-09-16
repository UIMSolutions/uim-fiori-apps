sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
    "use strict";
    return UIComponent.extend("landscape.frontend.Component", {
        metadata: {
            manifest: "json"
        },
        init: function () {
            UIComponent.prototype.init.apply(this, arguments);
            var detailModel = new JSONModel({
                selectedSystem: {},
                interfaces: [],
                graphNodes: [],
                graphLines: []
            });
            this.setModel(detailModel, "detail");
            var filterModel = new JSONModel({
                criticality: "",
                operatingModel: "",
                lifecycleStatus: "",
                query: ""
            });
            this.setModel(filterModel, "filters");
        }
    });
});
