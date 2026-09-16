module uim.fiori.materials.presentation.ui5.views.app;
import uim.fiori.views.view;

@safe:
class AppView : UI5View {
    this(string path) {
        super(path);
    }

    override void buildView() {
        _writer.addElement("mvc:View")
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
            _writer.addElement("pages");
            addPage(["title": "Material - Cockpit"]);
            _writer.endElement(); // pages
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
            _writer.addElement("content");
            addIconTabBar();
            _writer.endElement(); // content 
        });
    }

    override void addIconTabBar(string[string] values = null, scope void delegate() @safe content = null) {
        super.addIconTabBar(["expandable": "false"], {
            addElement("items", null, {
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
                        addSupplierForm();
                        addSuppliersTable();
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
                        addHBox(["renderType": "Bare"], {
                            addWarehousesTable();
                            addTable([
                                "id": "assignmentsTable",
                                "width": "52%",
                                "items": "{/WarehouseAssignments}"
                            ], {
                                addElement("headerToolbar", null, {
                                    addToolbar(null, {
                                        addTitle("{i18n>materialWarehouseAssignment}");
                                    });
                                });
                                addColumns([
                                    "{i18n>id}", "{i18n>materialId}",
                                    "{i18n>warehouseId}"
                                ]);
                                addElement("items", null, {
                                    addElement("ColumnListItem", null, {
                                        addElement("cells", null, {
                                            addText("{ID}");
                                            addText("{MaterialID}");
                                            addText("{WarehouseID}");
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    }

    void addMaterialForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>materialCreate}"
        ], {
            _writer.addElement(
                "layout:content");
            addLabel("{i18n>name}");
            addInput(
                [
                    "id": "materialNameInput"
                ]);
            addLabel("{i18n>description}");
            addInput(
                [
                    "id": "materialDescriptionInput"
                ]);
            addLabel("{i18n>target}");
            addInput([
                    "id": "materialTargetStockInput",
                    "type": "Number"
                ]);
            addButton([
                "text": "{i18n>materialCreate}",
                "type": "Emphasized",
                "press": "onCreateMaterial"
            ]);
            _writer.endElement(); // layout:content
        });
    }

    void addSupplierForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>supplierCreate}"
        ], {
            _writer.addElement(
                "layout:content");
            addLabel("{i18n>name}");
            addInput(
                [
                    "id": "supplierNameInput"
                ]);
            addLabel("{i18n>contactInfo}");
            addInput(
                [
                    "id": "supplierContactInfoInput"
                ]);
            addLabel(
                "{i18n>description}");
            addInput(
                [
                    "id": "supplierDescriptionInput"
                ]);
            addButton([
                "text": "{i18n>supplierCreate}",
                "type": "Emphasized",
                "press": "onCreateSupplier"
            ]);
            _writer.endElement(); // layout:content
        });
    }

    void addPlanningForm() {
        addSimpleForm([
            "editable": "true",
            "layout": "ResponsiveGridLayout",
            "title": "{i18n>materialPlanning}"
        ], {
            _writer.addElement(
                "layout:content");
            addLabel(
                "{i18n>material}");
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
            addLabel(
                "{i18n>planningDate}");
            addDatePicker([
                "id": "planDateInput",
                "valueFormat": "yyyy-MM-dd",
                "displayFormat": "yyyy-MM-dd"
            ]);
            addLabel(
                "{i18n>plannedQuantity}");
            addInput([
                    "id": "planQuantityInput",
                    "type": "Number"
                ]);
            addButton(
                [
                "text": "{i18n>planningSave}",
                "type": "Emphasized",
                "press": "onCreatePlan"
            ]);
            _writer.endElement(); // layout:content
        });
    }

    void addMaterialsTable() {
        addTable([
                "id": "materialsTable",
                "items": "{/Materials}"
            ], {
            _writer.addElement(
                "headerToolbar");
            addToolbar(null, { addTitle(
                "{i18n>materials}"); });
            _writer.endElement(); // headerToolbar
            addColumns([
                "{i18n>id}",
                "{i18n>name}",
                "{i18n>description}",
                "{i18n>target}"
            ]);
            _writer.addElement(
                "items");
            addColumnListItem([
                    "type": "Active"
                ], {
                addElement("cells", null, {
                    addText(
                    "{ID}");
                    addText(
                    "{Name}");
                    addText(
                    "{Description}");
                    addObjectNumber(
                    [
                        "number": "{TargetStock}"
                    ]);
                });
            });
            _writer.endElement(); // items
        });
    }

    void addSuppliersTable() {
        addTable([
                "id": "suppliersTable",
                "items": "{/Suppliers}"
            ], {
            _writer.addElement(
                "headerToolbar");
            addToolbar(null, { addTitle(
                "{i18n>suppliers}"); });
            _writer.endElement(); // headerToolbar
            addColumns([
                    "{i18n>id}",
                    "{i18n>name}",
                    "{i18n>contactInfo}",
                    "{i18n>description}"
                ]);
            _writer.addElement(
                "items");
            addColumnListItem(
                [
                    "type": "Active"
                ], {
                addElement("cells", null, {
                    addText(
                    "{ID}");
                    addText(
                    "{Name}");
                    addText(
                    "{ContactInfo}");
                    addText(
                    "{Description}");
                });
            });
            _writer.endElement(); // items
        });
    }

    void addPlanningTable() {
        addTable([
                "id": "plansTable",
                "items": "{/MaterialPlans}"
            ], {
            addElement("headerToolbar", null, {
                addToolbar(null, { addTitle(
                "{i18n>planning}"); });
            });
            addColumns([
                "{i18n>id}",
                "{i18n>materialId}",
                "{i18n>planningDate}",
                "{i18n>plannedQuantity}"
            ]);
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(
                        "{ID}");
                        addText(
                        "{MaterialID}");
                        addText(
                        "{PlannedDate}");
                        addObjectNumber([
                            "number": "{PlannedQuantity}"
                        ]);
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
                addLabel(
                    "{i18n>warehouse}");
                addSelect(
                    [
                        "id": "warehouseSelect",
                        "items": "{lookup>/warehouses}"
                    ], {
                    addElement("core:Item", [
                        "key": "{lookup>ID}",
                        "text": "{lookup>Name}"
                    ]);
                });
                addLabel(
                    "{i18n>storage}");
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
                addToolbar(null, { addTitle(
                    "{i18n>warehouses}"); });
            });
            addColumns([
                    "{i18n>id}",
                    "{i18n>name}",
                    "{i18n>location}"
                ]);
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(
                        "{ID}");
                        addText(
                        "{Name}");
                        addText(
                        "{Location}");
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
                    addTitle("{i18n>materialWarehouseAssignment}");
                });
            });
            addColumns([
                    "{i18n>id}",
                    "{i18n>materialId}",
                    "{i18n>warehouseId}"
                ]);
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(
                        "{ID}");
                        addText(
                        "{MaterialID}");
                        addText(
                        "{WarehouseID}");
                    });
                });
            });
        });
    }

    void addEvaluationToolbar() {
        addToolbar(null, {
            addTitle(
                "{i18n>stockEvaluation}");
            addToolbarSpacer();
            addButton(
                [
                    "text": "{i18n>refresh}",
                    "press": "onRefreshEvaluations"
                ]);
        });
    }

    void addEvaluationsTable() {
        addTable([
                "id": "evaluationsTable",
                "items": "{/StockEvaluations}"
            ], {
            addColumns([
                "{i18n>material}",
                "{i18n>available}",
                "{i18n>target}",
                "{i18n>status}"
            ]);
            addElement("items", null, {
                addColumnListItem(null, {
                    addElement("cells", null, {
                        addText(
                        "{MaterialName}");
                        addObjectNumber(
                        [
                            "number": "{Available}",
                            "unit": "Stk"
                        ]);
                        addObjectNumber(
                        [
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

    auto view = new AppView(
        "/views/App.view.xml");
    writeln(view.render());
}
