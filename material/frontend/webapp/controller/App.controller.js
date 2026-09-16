sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "material/frontend/model/models",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/resource/ResourceModel"
  ],
  function (Controller, MessageToast, models, JSONModel, ResourceModel) {
    "use strict";
    return Controller.extend("material.frontend.controller.App", {
      onInit: function () {
        // 1. Get the language automatically detected by SAPUI5 from the browser
        var sBrowserLang = sap.ui.getCore().getConfiguration().getLanguage(); // e.g., "en-US" or "de"
        console.log("Detected browser language:", sBrowserLang);
        var sShortLang = sBrowserLang.substring(0, 2); // Get first 2 letters (e.g., "en", "de")
        console.log("Detected short language:", sShortLang);
        // Fallback to "en" if it's something else entirely, or keep if supported
        if (sShortLang !== "en" && sShortLang !== "de") {
          sShortLang = "en";
        }
        console.log("Final language to be used:", sShortLang);
        // 2. Set up a local view model to keep track of the current language
        var oViewModel = new JSONModel({
          currentLanguage: sShortLang,
        });
        this.getView().setModel(oViewModel, "viewModel");
        // 3. Ensure the i18n model uses this browser-detected language bundle initially
        var oi18nModel = new ResourceModel({
          bundleName: "material.frontend.i18n.i18n",
          bundleLocale: sShortLang,
        });
        this.getOwnerComponent().setModel(oi18nModel, "i18n");
        this.getView().setModel(models.createLookupModel(), "lookup");
        this._refreshLookupData();
      },
      onCreateMaterial: async function () {
        var name = this.byId("materialNameInput").getValue().trim();
        var description = this.byId("materialDescriptionInput")
          .getValue()
          .trim();
        var targetStock = Number(
          this.byId("materialTargetStockInput").getValue() || 0,
        );
        if (!name) {
          MessageToast.show("Bitte einen Materialnamen eingeben.");
          return;
        }
        var oControl = this.byId("materialsTable");
        // console.log("Found control:", oControl);
        var binding = oControl.getBinding("items");
        var context = binding.create({
          Name: name,
          Description: description,
          TargetStock: targetStock,
        });
        await context.created();
        this.byId("materialNameInput").setValue("");
        this.byId("materialDescriptionInput").setValue("");
        this.byId("materialTargetStockInput").setValue("");
        this._refreshLookupData();
        this.byId("evaluationsTable").getBinding("items").refresh();
        MessageToast.show("Material erstellt");
      },
      onCreatePlan: async function () {
        var materialId = this.byId("planMaterialSelect").getSelectedKey();
        var plannedDate = this.byId("planDateInput").getValue();
        var plannedQuantity = Number(
          this.byId("planQuantityInput").getValue() || 0,
        );
        if (!materialId || !plannedDate || plannedQuantity <= 0) {
          MessageToast.show("Bitte Material, Datum und Menge angeben.");
          return;
        }
        var binding = this.byId("plansTable").getBinding("items");
        var context = binding.create({
          MaterialID: materialId,
          PlannedDate: plannedDate,
          PlannedQuantity: plannedQuantity,
        });
        await context.created();
        this.byId("planQuantityInput").setValue("");
        MessageToast.show("Planung gespeichert");
      },
      onCreateAssignment: async function () {
        var materialId = this.byId("assignmentMaterialSelect").getSelectedKey();
        var warehouseId = this.byId(
          "assignmentWarehouseSelect",
        ).getSelectedKey();
        if (!materialId || !warehouseId) {
          MessageToast.show("Bitte Material und Lager auswaehlen.");
          return;
        }
        var binding = this.byId("assignmentsTable").getBinding("items");
        var context = binding.create({
          MaterialID: materialId,
          WarehouseID: warehouseId,
        });
        await context.created();
        MessageToast.show("Zuordnung gespeichert");
      },
      onRefreshEvaluations: function () {
        this.byId("evaluationsTable").getBinding("items").refresh();
      },
      _refreshLookupData: async function () {
        var lookupModel = this.getView().getModel("lookup");
        var [materials, warehouses] = await Promise.all([
          this._readCollection("Materials"),
          this._readCollection("Warehouses"),
        ]);
        lookupModel.setData({
          materials: materials,
          warehouses: warehouses,
        });
      },
      _readCollection: async function (entitySetName) {
        var response = await fetch(
          "/odata/v4/material-service/" + entitySetName,
        );
        if (!response.ok) {
          return [];
        }
        var body = await response.json();
        return body.value || [];
      },
      onLanguageChange: function (oEvent) {
        // Get the selected key directly from the Select control
        var sSelectedLocale = oEvent.getSource().getSelectedKey();
        // 1. Set the global UI5 configuration language
        sap.ui.getCore().getConfiguration().setLanguage(sSelectedLocale);
        // 2. Create a new ResourceModel with the target locale bundle
        var oi18nModel = new ResourceModel({
          bundleName: "material.frontend.i18n.i18n",
          bundleLocale: sSelectedLocale,
        });
        // 3. Replace the old i18n model globally
        this.getOwnerComponent().setModel(oi18nModel, "i18n");
      },
    });
  },
);
