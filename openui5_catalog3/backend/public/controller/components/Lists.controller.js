sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("my.app.controller.components.Lists", {
        
        onInit: function () {
            var oData = {
                items: [
                    { title: "Review Vibe.d Architecture", description: "Backend server sync requirements", icon: "sap-icon://server", status: "Urgent", state: "Error" },
                    { title: "Optimize UI5 Router", description: "Validate route parameter name mappings", icon: "sap-icon://journey-arrive", status: "In Progress", state: "Warning" },
                    { title: "Test FCL 3-Column Layout", description: "Check view injection and owner bindings", icon: "sap-icon://largetable", status: "Completed", state: "Success" },
                    { title: "Add New Controls", description: "Expand component explorer inventory", icon: "sap-icon://add", status: "Pending", state: "None" }
                ]
            };

            var oModel = new JSONModel(oData);
            this.getView().setModel(oModel);
            console.log("List component view initialized successfully.");
        },

        onDeleteSelected: function () {
            var oList = this.byId("itemList");
            var aSelectedItems = oList.getSelectedItems();
            
            if (aSelectedItems.length > 0) {
                var oModel = this.getView().getModel();
                var aData = oModel.getProperty("/items");
                
                // Filter out selected items
                var aRemaining = aData.filter(function(oItem, index) {
                    var bSelected = aSelectedItems.some(function(oSelItem) {
                        return oList.indexOfItem(oSelItem) === index;
                    });
                    return !bSelected;
                });

                oModel.setProperty("/items", aRemaining);
                oList.removeSelections(true);
                
                MessageToast.show(aSelectedItems.length + " item(s) removed.");
                this.byId("listStatusLabel").setText("Status: Removed " + aSelectedItems.length + " items.");
            } else {
                MessageToast.show("Please select at least one item to delete.");
            }
        }

    });
});