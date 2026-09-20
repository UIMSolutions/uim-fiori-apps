sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast"
], function (Controller, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.ImageEditors", {
        
        onInit: function () {
            console.log("ImageEditor component view initialized successfully.");
        },

        onImageLoaded: function () {
            MessageToast.show("Image loaded into editor.");
            this.byId("editorStatusLabel").setText("Status: Image successfully loaded and ready for editing.");
        },

        onRotateLeft: function () {
            var oEditor = this.byId("myImageEditor");
            oEditor.rotate(-90);
            MessageToast.show("Rotated 90° Left");
            this.byId("editorStatusLabel").setText("Status: Image rotated counter-clockwise.");
        },

        onRotateRight: function () {
            var oEditor = this.byId("myImageEditor");
            oEditor.rotate(90);
            MessageToast.show("Rotated 90° Right");
            this.byId("editorStatusLabel").setText("Status: Image rotated clockwise.");
        },

        onZoomToFit: function () {
            var oEditor = this.byId("myImageEditor");
            oEditor.zoomToFit();
            MessageToast.show("Zoomed to fit container");
            this.byId("editorStatusLabel").setText("Status: Applied zoom-to-fit scaling.");
        }

    });
});