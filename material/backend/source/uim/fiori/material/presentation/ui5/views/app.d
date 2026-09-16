module uim.fiori.material.presentation.ui5.views.app;
import uim.fiori.views.view;
@safe:
class AppView : UI5View {
    this(string path) {
        super(path);
    }
    override void buildView() {
        writer.addElement("mvc:View")
            .addAttributes([
                "controllerName": "material.frontend.controller.App",
                "xmlns:mvc": "sap.ui.core.mvc",
                "xmlns": "sap.m",
                "xmlns:layout": "sap.ui.layout.form",
                "xmlns:core": "sap.ui.core",
                "height": "100%"
            ]);
        addApp();
    }
    override void addApp(string[string] values = null, scope void delegate() @safe content = null) {
        super.addApp(values, {
            writer.addElement("pages");
            addPage(["title": "Material - Cockpit"]);
            writer.endElement(); // pages
        });
    }
    override void addPage(string[string] values = null, scope void delegate() @safe content = null) {
        super.addPage(values, {
            addElement("headerContent", null, {
                addSelect([
                    "change": ".onLanguageChange",
                    "selectedKey": "{viewModel>/currentLanguage}"
                ], {
                    addCoreItem(["key": "en", "text": "English"]);
                    addCoreItem(["key": "de", "text": "Deutsch"]);
                });
            });
            writer.addElement("content");
            addIconTabBar();
            writer.endElement(); // content 
        });
    }

    void addIconTabBar() {
        writer.addElement("IconTabBar")
            .addAttributes(["expandable": "false"])
            .addElement("items");
        addIconTabFilter([
            "key": "materials",
            "text": "{i18n>materials}",
            "icon": "sap-icon://product"
        ], {
            addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                addMaterialForm();
                addMaterialsTable();
            });
        });
        addIconTabFilter([
            "key": "planning",
            "text": "{i18n>planning}",
            "icon": "sap-icon://calendar"
        ], {
            addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                addPlanningForm();
                addPlanningTable();
            });
        });
        addIconTabFilter([
            "key": "suppliers",
            "text": "{i18n>suppliers}",
            "icon": "sap-icon://supplier"
        ], {
            addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                // addSupplierForm();
                // addSuppliersTable();
            });
        });
        addIconTabFilter([
            "key": "evaluations",
            "text": "{i18n>stockEvaluation}",
            "icon": "sap-icon://business-objects-experience"
        ], {
            addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                addEvaluationToolbar();
                addEvaluationsTable();
            });
        });
        addIconTabFilter([
            "key": "warehouses",
            "text": "{i18n>warehouses}",
            "icon": "sap-icon://shipping-status"
        ], {
            addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                addWarehouseForm();
                // addHBox(["renderType": "Bare"], { addWarehousesTable(); });
            });
        });
        writer.endElement(); // items
        writer.endElement(); // IconTabBar
    }

    void addIconTabFilter(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("IconTabFilter", values, content);
    }

    void addMaterialForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>materialCreate}"
        ], {
            writer.addElement("layout:content");
            addLabel("{i18n>name}");
            addInput(["id": "materialNameInput"]);
            addLabel("{i18n>description}");
            addInput(["id": "materialDescriptionInput"]);
            addLabel("{i18n>target}");
            addInput(["id": "materialTargetStockInput", "type": "Number"]);
            addButton([
                "text": "{i18n>materialCreate}",
                "type": "Emphasized",
                "press": "onCreateMaterial"
            ]);
            writer.endElement(); // layout:content
        });
    }

    void addPlanningForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>materialPlanning}"
        ], {
            writer.addElement("layout:content");
            addLabel("{i18n>material}");
            addSelect([
                "id": "planMaterialSelect",
                "items": "{lookup>/materials}"
            ], {
                addElement("core:Item", [
                        "xmlns:core": "sap.ui.core",
                        "key": "{lookup>ID}",
                        "text": "{lookup>Name}"
                    ]);
            });
            addLabel("{i18n>planningDate}");
            addDatePicker([
                "id": "planDateInput",
                "valueFormat": "yyyy-MM-dd",
                "displayFormat": "yyyy-MM-dd"
            ]);
            addLabel("{i18n>plannedQuantity}");
            addInput(["id": "planQuantityInput", "type": "Number"]);
            addButton([
                "text": "{i18n>planningSave}",
                "type": "Emphasized",
                "press": "onCreatePlan"
            ]);
            writer.endElement(); // layout:content
        });
    }

    void addMaterialsTable() {
        addTable(["id": "materialsTable", "items": "{/Materials}"], {
            writer.addElement("headerToolbar");
            addToolbar(null, {
                addElement("Title", ["text": "{i18n>materials}"]);
            });
            writer.endElement(); // headerToolbar
            writer.addElement("columns");
            addMaterialColumns();
            writer.endElement(); // columns
            writer.addElement("items");
            addColumnListItem(["type": "Active"], {
                addElement("cells", null, {
                    addText("{ID}");
                    addText("{Name}");
                    addText("{Description}");
                    addObjectNumber(["number": "{TargetStock}"]);
                });
            });
            writer.endElement(); // items
        });
    }
    // override
    // void addTable(string[string] values = null, scope void delegate() @safe content = null) {
    //     super.addTable(["id": "materialsTable", "items": "{/Materials}"], {
    //         writer.addElement("headerToolbar");
    //         writer.addElement("Toolbar");
    //         addElement("Title", ["text": "Materialien"]);
    //         writer.endElement(); // Toolbar
    //         writer.endElement(); // headerToolbar
    //         writer.addElement("columns");
    //         addMaterialColumns();
    //         writer.endElement(); // columns
    //         writer.addElement("items");
    //         addColumnListItem(["type": "Active"], {
    //             addElement("cells", null, {
    //                 addText(["text": "{ID}"]);
    //                 addText(["text": "{Name}"]);
    //                 addText(["text": "{Description}"]);
    //                 addObjectNumber(["number": "{TargetStock}"]);
    //             });
    //         });
    //         writer.endElement(); // items
    //     });
    // }

    void addMaterialColumns() {
        addColumns(["{i18n>id}", "{i18n>name}", "{i18n>description}", "{i18n>target}"]);
    }

    void addPlanningTable() {
        addTable(["id": "plansTable", "items": "{/MaterialPlans}"], {
            addElement("headerToolbar", null, {
                addToolbar(null, { addElement("Title", ["text": "Planungen"]); });
            });
            addElement("columns", null, {
                addElement("Column", null, { 
                    addText("{i18n>id}"); 
                });
                addElement("Column", null, {
                    addText("{i18n>materialId}");
                });
                addElement("Column", null, {
                    addText("{i18n>planningDate}");
                });
                addElement("Column", null, {
                    addText("{i18n>plannedQuantity}");
                });
            });
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(["text": "{ID}"]);
                        addText(["text": "{MaterialID}"]);
                        addText(["text": "{PlannedDate}"]);
                        addObjectNumber(["number": "{PlannedQuantity}"]);
                    });
                });
            });
        });
    }

    void addWarehouseForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>assignWarehouse}"
        ], {
            addElement("layout:content", null, {
                addLabel("{i18n>warehouse}");
                addSelect([
                    "id": "warehouseSelect",
                    "items": "{lookup>/warehouses}"
                ], {
                    addElement("core:Item", [
                            "key": "{lookup>ID}",
                            "text": "{lookup>Name}"
                        ]);
                });
                addLabel("{i18n>storage}");
                addSelect([
                    "id": "assignmentWarehouseSelect",
                    "items": "{lookup>/warehouses}"
                ], {
                    addElement("core:Item", [
                            "key": "{lookup>ID}",
                            "text": "{lookup>Name}"
                        ]);
                });
                addButton([
                    "text": "{i18n>saveAssignment}",
                    "type": "Emphasized",
                    "press": "onCreateAssignment"
                ]);
            });
        });
    }

    void addWarehousesTable() {
        addTable([
            "id": "warehousesTable",
            "width": "48%",
            "items": "{/Warehouses}",
            "class": "sapUiSmallMarginEnd"
        ], {
            addElement("headerToolbar", null, {
                addToolbar(null, { addTitle(["text": "{i18n>warehouse}"]); });
            });
            addElement("columns", null, {
                addColumn(null, { addText(["text": "{i18n>id}"]); });
                addColumn(null, { addText(["text": "{i18n>name}"]); });
                addColumn(null, { addText(["text": "{i18n>location}"]); });
            });
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(["text": "{ID}"]);
                        addText(["text": "{Name}"]);
                        addText(["text": "{Location}"]);
                    });
                });
            });
        });
    }

    void addAssignmentsTable() {
        addTable([
            "id": "assignmentsTable",
            "width": "52%",
            "items": "{/WarehouseAssignments}"
        ], {
            addElement("headerToolbar", null, {
                addToolbar(null, {
                    addTitle(["text": "{i18n>materialWarehouseAssignment}"]);
                });
            });
            addElement("columns", null, {
                addColumn(null, { addText(["text": "{i18n>id}"]); });
                addColumn(null, { addText(["text": "{i18n>materialId}"]); });
                addColumn(null, { addText(["text": "{i18n>warehouseId}"]); });
            });
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(["text": "{ID}"]);
                        addText(["text": "{MaterialID}"]);
                        addText(["text": "{WarehouseID}"]);
                    });
                });
            });
        });
    }

    void addEvaluationToolbar() {
        addToolbar(null, {
            addTitle(["text": "{i18n>stockEvaluation}"]);
            addToolbarSpacer();
            addButton([
                "text": "{i18n>refresh}",
                "press": "onRefreshEvaluations"
            ]);
        });
    }

    void addEvaluationsTable() {
        addTable(["id": "evaluationsTable", "items": "{/StockEvaluations}"], {
            addElement("columns", null, {
                addColumn(null, { addText(["text": "{i18n>material}"]); });
                addColumn(null, { addText(["text": "{i18n>available}"]); });
                addColumn(null, { addText(["text": "{i18n>target}"]); });
                addColumn(null, { addText(["text": "{i18n>status}"]); });
            });
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(["text": "{MaterialName}"]);
                        addObjectNumber(["number": "{Available}", "unit": "Stk"]);
                        addObjectNumber([
                            "number": "{TargetStock}",
                            "unit": "Stk"
                        ]);
                        addObjectStatus([
                            "text": "{Status}",
                            "state": "{= ${Status} === 'OK' ? 'Success' : 'Error'}"
                        ]);
                    });
                });
            });
        });
    }
}
///
unittest {
    import std.stdio;
    auto view = new AppView("/views/App.view.xml");
    writeln(view.render());
}
