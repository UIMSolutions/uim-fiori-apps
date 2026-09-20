sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/UIComponent",
    "sap/m/MessageToast",
  ],
  function (Controller, UIComponent, MessageToast) {
    "use strict";

    // Map URL parameter keys to target XML view names under my/app/view/components/
    var mComponentViews = {
      avatars: "Avatars", // Maps to my.app.view.components.Avatars
      buttons: "Buttons",
      inputs: "Inputs",
      // Add additional component mappings here as needed
    };

    return Controller.extend("my.app.controller.SubDetail", {
      onInit: function () {
        var oRouter = UIComponent.getRouterFor(this);
        var oRoute = oRouter.getRoute("subDetail"); // Fixed to match manifest.json route name

        if (oRoute) {
          oRoute.attachPatternMatched(this._onRouteMatched, this);
        } else {
          console.warn("Route 'subDetail' not found in routing configuration.");
        }
      },

      _onRouteMatched: function (oEvent) {
        var oArgs = oEvent.getParameter("arguments");
        var sComponentKey = oArgs.componentId
          ? oArgs.componentId.toLowerCase()
          : "";

        var sViewName = mComponentViews[sComponentKey];
        var oPageContainer = this.byId("componentDisplayPage"); // Direkter Zugriff auf die Page

        if (!oPageContainer) {
          console.error(
            "Critical: 'componentDisplayPage' not found in SubDetail view.",
          );
          return;
        }

        // 1. Alte Inhalte sicher löschen
        oPageContainer.destroyContent();

        if (sViewName) {
            console.log("Loading view for component key:", sComponentKey);
            console.log("Resolved view name:", sViewName);
            console.log("Page container found:", !!oPageContainer);
            
          // 2. Neue Komponente dynamisch laden und einfügen
          this.load({
            name: "my.app.view.components." + sViewName,
            type: "XML",
          })
            .then(function (oView) {
              oPageContainer.addContent(oView); // Fügt die View zur Page hinzu
            })
            .catch(function (oError) {
              console.error("Fehler beim Laden der View: " + sViewName, oError);
              MessageToast.show("Fehler beim Laden der Komponente.");
            });
        } else {
          MessageToast.show(
            "Ausgewählte Komponente ist noch nicht zugeordnet.",
          );
        }
      },
      onCloseSubDetail: function () {
        var oArgs = this._oLastArgs || {};
        var aHashParts = this.getOwnerComponent()
          .getRouter()
          .getHashChanger()
          .getHash()
          .split("/");
        var sNamespaceId = aHashParts[1] || "";

        // Collapse column 3 back to 2 columns layout
        this.getOwnerComponent().getRouter().navTo("detail", {
          namespaceId: sNamespaceId,
          layout: "TwoColumnsMidExpanded",
        });
      },
    });
  },
);
