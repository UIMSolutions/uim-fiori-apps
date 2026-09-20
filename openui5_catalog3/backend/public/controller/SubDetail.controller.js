sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/UIComponent",
    "sap/ui/core/mvc/XMLView",
    "sap/m/MessageToast",
  ],
  function (Controller, UIComponent, XMLView, MessageToast) {
    "use strict";

    // Map URL parameter keys to target XML view names under my/app/view/components/
    var mComponentViews = {
      avatars: "Avatars", // Maps to my.app.view.components.Avatars
      buttons: "Buttons",
      inputs: "Inputs",
      labels: "Labels",
      bars: "Bars",
      breadcrumbs: "Breadcrumbs",
      checkboxes: "Checkboxes",
      carousels: "Carousels",
      expandabletexts: "ExpandableTexts",
      menus: "Menus",
      pdfviewers: "PdfViewers",
      generictiles: "GenericTiles",
      datepickers: "DatePickers",
      lists: "Lists",
      trees: "Trees",
      feedcontents: "FeedContents",
      images: "Images",
      objectnumbers: "ObjectNumbers",
      wizards: "Wizards",
      newscontents: "NewsContents",
      slidetiles: "SlideTiles",
      tilecontents: "TileContents",
      wheelsliders: "WheelSliders",
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
        var oPageContainer = this.byId("componentDisplayPage");

        if (!oPageContainer) {
          console.error(
            "Critical: 'componentDisplayPage' not found in SubDetail view.",
          );
          return;
        }

        // Alte Inhalte sicher löschen
        oPageContainer.destroyContent();

        if (sViewName) {
          console.log(
            "Try to load view for component: my.app.view.components." +
              sViewName,
          );

          // KORREKT: XMLView.create statt this.load
          XMLView.create({
            viewName: "my.app.view.components." + sViewName,
          })
            .then(function (oView) {
              oPageContainer.addContent(oView);
              console.log("Successfully rendered component view: " + sViewName);
            })
            .catch(function (oError) {
              console.error(
                "Failed to load view for component: " + sViewName,
                oError,
              );
              MessageToast.show("Error loading component view.");
            });
        } else {
          console.warn(
            "No view mapping registered for key: '" + sComponentKey + "'",
          );
          MessageToast.show("Selected component view is not yet mapped.");
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
