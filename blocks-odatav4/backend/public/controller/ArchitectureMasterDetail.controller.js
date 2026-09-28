sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/f/library",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/core/Item"
], function (Controller, fLibrary, Filter, FilterOperator, Item) {
    "use strict";

    var LayoutType = fLibrary.LayoutType;

    return Controller.extend("ea.architecture.manager.controller.ArchitectureMasterDetail", {

        onInit: function () {
            this._sMasterQuery = "";
            this._sModuleFilter = "";
            this._bModuleFilterInitialized = false;

            var oList = this.byId("masterList");
            if (oList) {
                oList.attachUpdateFinished(this._updateModuleFilterOptions, this);
            }
        },

        onMasterListSearch: function (oEvent) {
            var sQuery = oEvent.getParameter("newValue");
            if (typeof sQuery !== "string") {
                sQuery = oEvent.getParameter("query") || "";
            }

            this._sMasterQuery = sQuery.trim();
            this._applyMasterListFilters();
        },

        onModuleFilterChange: function (oEvent) {
            var sKey = oEvent.getParameter("selectedItem").getKey();
            this._sModuleFilter = sKey === "__ALL__" ? "" : sKey;
            this._applyMasterListFilters();
        },

        _applyMasterListFilters: function () {
            var oList = this.byId("masterList");
            if (!oList) {
                return;
            }

            var oBinding = oList.getBinding("items");
            if (!oBinding) {
                return;
            }

            var aFilters = [];
            if (this._sMasterQuery) {
                aFilters.push(new Filter({
                    filters: [
                        new Filter("ID", FilterOperator.Contains, this._sMasterQuery),
                        new Filter("Name", FilterOperator.Contains, this._sMasterQuery),
                        new Filter("Modul", FilterOperator.Contains, this._sMasterQuery),
                        new Filter("Responsible", FilterOperator.Contains, this._sMasterQuery)
                    ],
                    and: false
                }));
            }

            if (this._sModuleFilter) {
                aFilters.push(new Filter("Modul", FilterOperator.EQ, this._sModuleFilter));
            }

            oBinding.filter(aFilters);
        },

        _updateModuleFilterOptions: function () {
            if (this._bModuleFilterInitialized) {
                return;
            }

            var oList = this.byId("masterList");
            var oSelect = this.byId("moduleFilter");

            if (!oList || !oSelect) {
                return;
            }

            var mModules = Object.create(null);
            oList.getItems().forEach(function (oItem) {
                var oContext = oItem.getBindingContext();
                var sModule = oContext && oContext.getProperty("Modul");
                if (sModule) {
                    mModules[sModule] = true;
                }
            });

            var aModules = Object.keys(mModules).sort(function (a, b) {
                return a.localeCompare(b);
            });

            if (!aModules.length) {
                return;
            }

            oSelect.removeAllItems();
            oSelect.addItem(new Item({ key: "__ALL__", text: "Alle Module" }));
            aModules.forEach(function (sModule) {
                oSelect.addItem(new Item({ key: sModule, text: sModule }));
            });
            oSelect.setSelectedKey("__ALL__");

            this._bModuleFilterInitialized = true;
            oList.detachUpdateFinished(this._updateModuleFilterOptions, this);
        },

        onListItemPress: function (oEvent) {
            var oListItem = oEvent.getParameter("listItem") || oEvent.getSource();
            var oContext = oListItem.getBindingContext();

            if (!oContext) {
                console.error("Kein BindingContext vorhanden!");
                return;
            }

            var oFCL = this.byId("fcl");
            var oDetailPage = this.byId("detailPage");

            if (oDetailPage && oFCL) {
                // 1. Kontext zuweisen
                oDetailPage.setBindingContext(oContext);

                // 2. Daten laden abwarten und erst dann Layout erweitern
                oContext.requestObject().then(function () {
                    oFCL.setLayout(LayoutType.TwoColumnsMidExpanded);
                }).catch(function (oError) {
                    console.error("Fehler beim Laden der Detailsicht:", oError);
                });
            }
        },

        // Formatter für den ObjectStatus
        formatCriticalityState: function (sCriticality) {
            switch (sCriticality) {
                case "High":
                    return "Error";
                case "Medium":
                    return "Warning";
                case "Low":
                    return "Success";
                default:
                    return "None";
            }
        },

        onDependencyPress: function (oEvent) {
            var oItem = oEvent.getSource();
            var oDependencyContext = oItem.getBindingContext();
            var sTargetId = oDependencyContext.getProperty("ID");

            if (!sTargetId) {
                return;
            }

            console.log("Wechsle im Detailbereich zu ID:", sTargetId);

            var oModel = this.getView().getModel();
            var oDetailPage = this.byId("detailPage");
            var oFCL = this.byId("fcl");
            var oMasterList = this.byId("masterList");

            // 1. OData v4 Key-Binding für den Ziel-Baustein erstellen
            var sPath = "/ArchitectureBlocks('" + sTargetId + "')";
            var oTargetContext = oModel.bindContext(sPath).getBoundContext();

            // 2. Kontext an die Detailseite binden
            oDetailPage.setBindingContext(oTargetContext);

            // 3. In der Master-Liste das entsprechende Item selektieren (falls vorhanden)
            if (oMasterList) {
                var aItems = oMasterList.getItems();
                aItems.forEach(function (oListItem) {
                    var oCtx = oListItem.getBindingContext();
                    if (oCtx && oCtx.getProperty("ID") === sTargetId) {
                        oMasterList.setSelectedItem(oListItem);
                    }
                });
            }

            // 4. Daten laden abwarten und FCL-Layout aufklappen
            oTargetContext.requestObject().then(function () {
                if (oFCL) {
                    oFCL.setLayout(sap.f.LayoutType.TwoColumnsMidExpanded);
                }
            }).catch(function (oError) {
                console.error("Fehler beim Laden des abhängigen Bausteins:", oError);
            });
        },

        onNavHome: function () {
            this.getOwnerComponent().getRouter().navTo("home");
        }
    });
});