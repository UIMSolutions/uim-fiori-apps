sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/UIComponent",
    "sap/m/MessageToast"
], function (Controller, UIComponent, MessageToast) {
    "use strict";

    // Comprehensive lookup map linking URL parameter keys to target XML view names
    var mComponentViews = {
        // Tables & Layouts
        "analyticaltable": "AnalyticalTable",
        "grids": "Grids",
        
        // Main Controls (sap.m)
        "buttons": "Buttons",
        "labels": "Labels",
        "inputs": "Inputs",
        "bars": "Bars",
        "checkbox": "Checkbox",
        "avatar": "Avatar",
        "carousel": "Carousel",
        "menu": "Menu",
        "pdfviewer": "PdfViewer",
        "generictile": "GenericTile",
        "datepicker": "DatePicker",
        "list": "List",
        "tree": "Tree",
        "feedcontent": "FeedContent",
        "image": "Image",
        "objectnumber": "ObjectNumber",
        "wizard": "Wizard",
        "newscontent": "NewsContent",
        "slidetile": "SlideTile",
        "tilecontent": "TileContent",

        // UX Extended Library (sap.uxap)
        "breadcrumbs": "BreadCrumbs",
        "objectpageheader": "ObjectPageHeader",

        // Suite Commons (sap.suite.ui.commons)
        "imageeditor": "ImageEditor",
        "areamicrochart": "AreaMicroChart",
        "bulletmicrochart": "BulletMicroChart",
        "linemicrochart": "LineMicroChart",
        "graph": "Graph"
    };

    return Controller.extend("my.app.controller.SubDetail", {
        
        onInit: function () {
            var oRouter = UIComponent.getRouterFor(this);
            var oRoute = oRouter.getRoute("componentDetail");
            
            if (oRoute) {
                oRoute.attachPatternMatched(this._onRouteMatched, this);
            } else {
                console.warn("Route 'componentDetail' not found in routing configuration.");
            }
        },

        _onRouteMatched: function (oEvent) {
            var oArgs = oEvent.getParameter("arguments");
            var sComponentKey = oArgs.component ? oArgs.component.toLowerCase() : "";
            
            var sViewName = mComponentViews[sComponentKey];
            var oPageContainer = this.byId("componentPageContainer");

            if (!oPageContainer) {
                console.error("Critical: 'componentPageContainer' container not found in SubDetail view.");
                return;
            }

            // Clear previous contents
            oPageContainer.destroyContent();

            if (sViewName) {
                // Dynamically load and inject the selected component view into Column 3
                this.load({
                    name: "my.app.view.components." + sViewName,
                    type: "XML"
                }).then(function (oView) {
                    oPageContainer.addContent(oView);
                    console.log("Successfully rendered component view: " + sViewName);
                }).catch(function (oError) {
                    console.error("Failed to load view for component: " + sViewName, oError);
                    MessageToast.show("Error loading component view.");
                });
            } else {
                console.warn("No view mapping registered for key: '" + sComponentKey + "'");
                MessageToast.show("Selected component view is not yet mapped.");
            }
        }

    });
});