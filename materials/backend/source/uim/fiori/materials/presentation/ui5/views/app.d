module uim.fiori.materials.presentation.ui5.views.app;

import uim.fiori.materials;

@safe:
class AppView : MvcView {
  SAPMLibrary m = new SAPMLibrary();

  this(string path) {
    super(path);
    m.prefix = "";
  }

  override protected UI5Element[] buildView() {
    writeln("AppView:Building view for path: " ~ _path);
    return [
      UI5Element("mvc:View", [
          "controllerName": "material.frontend.controller.App",
          "xmlns:mvc": "sap.ui.core.mvc",
          "xmlns": "sap.m",
          "xmlns:layout": "sap.ui.layout.form",
          "xmlns:core": "sap.ui.core",
          "height": "100%"
        ], addApp())
    ];
  }

  UI5Element[] addApp() {
    return [
      m.App([
          m.Element("pages", [
              addPage()
            ])
        ])
    ];

  }

  UI5Element addPage() {
    return m.Page(["title": "Material - Cockpit"], [
        m.Element("headerContent", [
            m.Select([
              "change": ".onLanguageChange",
              "selectedKey": "{viewModel>/currentLanguage}"
            ],
            [
              UI5Element("core:Item", ["key": "en", "text": "English"]),
              UI5Element("core:Item", [
                "key": "de",
                "text": "Deutsch"
              ])
            ])
          ]),
        m.Element("content", [
            addIconTabBar()
          ])
      ]);
  }

  UI5Element addIconTabBar() {
    return m.IconTabBar(["expandable": "false"], [
        m.Element("items", [
            m.IconTabFilter([
              "key": "materials",
              "text": "{i18n>materials}",
              "icon": "sap-icon://product"
            ],
            [
              m.VBox(["class": "sapUiSmallMargin", "renderType": "Bare"], [
                addMaterialForm(),
                addMaterialsTable()
              ])
            ]),
            m.IconTabFilter([
              "key": "planning",
              "text": "{i18n>planning}",
              "icon": "sap-icon://calendar"
            ],
            [
              m.VBox(["class": "sapUiSmallMargin", "renderType": "Bare"], [
                addPlanningForm(),
                addPlanningTable()
              ])
            ]),
            m.IconTabFilter([
              "key": "suppliers",
              "text": "{i18n>suppliers}",
              "icon": "sap-icon://supplier"
            ],
            [
              m.VBox(["class": "sapUiSmallMargin", "renderType": "Bare"], [
                addSupplierForm(),
                addSuppliersTable()
              ])
            ]),
            m.IconTabFilter([
              "key": "evaluations",
              "text": "{i18n>stockEvaluation}",
              "icon": "sap-icon://business-objects-experience"
            ],
            [
              m.VBox(["class": "sapUiSmallMargin", "renderType": "Bare"], [
                addEvaluationToolbar(),
                addEvaluationsTable()
              ])
            ]),
            m.IconTabFilter([
              "key": "warehouses",
              "text": "{i18n>warehouses}",
              "icon": "sap-icon://shipping-status"
            ],
            [
              m.VBox(["class": "sapUiSmallMargin", "renderType": "Bare"], [
                addWarehouseForm(),
                m.HBox(["renderType": "Bare"], [
                  addWarehousesTable(),
                  m.Table([
                    "id": "assignmentsTable",
                    "width": "52%",
                    "items": "{/WarehouseAssignments}"
                  ],
                  [
                    m.Element("headerToolbar", [
                      m.Toolbar([
                        m.Title("{i18n>materialWarehouseAssignment}")
                      ])
                    ]),
                    m.Columns([
                      "{i18n>id}", "{i18n>materialId}",
                      "{i18n>warehouseId}"
                    ]),
                    m.Element("items", [
                      m.ColumnListItem([
                        m.Element("cells", [
                          m.Text("{ID}"),
                          m.Text("{MaterialID}"),
                          m.Text("{WarehouseID}")
                        ])
                      ])
                    ])
                  ])
                ])
              ])
            ])
          ])
      ]);
  }

  UI5Element addMaterialForm() {
    return m.Element("layout:SimpleForm", [
        "editable": "true",
        "layout": "ResponsiveGridLayout",
        "title": "{i18n>materialCreate}"
      ], [
        m.Element(
          "layout:content", [
            m.Label("{i18n>name}"),
            m.Input(
            [
              "id": "materialNameInput"
            ]),
            m.Label("{i18n>description}"),
            m.Input(
            [
              "id": "materialDescriptionInput"
            ]),
            m.Label("{i18n>target}"),
            m.Input([
              "id": "materialTargetStockInput",
              "type": "Number"
            ]),
            m.Button([
              "text": "{i18n>materialCreate}",
              "type": "Emphasized",
              "press": "onCreateMaterial"
            ])
          ])
      ]);
  }

  UI5Element addSupplierForm() {
    return m.Element("layout:SimpleForm", [
        "editable": "true",
        "layout": "ResponsiveGridLayout",
        "title": "{i18n>supplierCreate}"
      ], [
        m.Element("layout:content", [
            m.Label("{i18n>name}"),
            m.Input(
            [
              "id": "supplierNameInput"
            ]),
            m.Label("{i18n>contactInfo}"),
            m.Input(
            [
              "id": "supplierContactInfoInput"
            ]),
            m.Label(
            "{i18n>description}"),
            m.Input(
            [
              "id": "supplierDescriptionInput"
            ]),
            m.Button([
              "text": "{i18n>supplierCreate}",
              "type": "Emphasized",
              "press": "onCreateSupplier"
            ])
          ])
      ]);
  }

  UI5Element addPlanningForm() {
    return m.Element("layout:SimpleForm", [
        "editable": "true",
        "layout": "ResponsiveGridLayout",
        "title": "{i18n>materialPlanning}"
      ], [
        m.Element(
          "layout:content", [
            m.Label(
            "{i18n>material}"),
            m.Select([
              "id": "planMaterialSelect",
              "items": "{lookup>/materials}"
            ],
            [
              m.Element("core:Item", [
                "xmlns:core": "sap.ui.core",
                "key": "{lookup>ID}",
                "text": "{lookup>Name}"
              ])
            ]),
            m.Label(
            "{i18n>planningDate}"),
            m.DatePicker([
              "id": "planDateInput",
              "valueFormat": "yyyy-MM-dd",
              "displayFormat": "yyyy-MM-dd"
            ]),
            m.Label(
            "{i18n>plannedQuantity}"),
            m.Input([
              "id": "planQuantityInput",
              "type": "Number"
            ]),
            m.Button(
            [
              "text": "{i18n>planningSave}",
              "type": "Emphasized",
              "press": "onCreatePlan"
            ])
          ]) // layout:content
      ]);
  }

  UI5Element addMaterialsTable() {
    return m.Table([
        "id": "materialsTable",
        "items": "{/Materials}"
      ], [
        m.Element(
          "headerToolbar", [
            m.Toolbar([m.Title(
              "{i18n>materials}")]),
          ]), // headerToolbar
        m.Columns([
          "{i18n>id}",
          "{i18n>name}",
          "{i18n>description}",
          "{i18n>target}"
        ]),
        m.Element(
          "items", [
            m.ColumnListItem([
              "type": "Active"
            ], [
              m.Element("cells", [
                m.Text(
                "{ID}"),
                m.Text(
                "{Name}"),
                m.Text(
                "{Description}"),
                m.ObjectNumber(
                [
                  "number": "{TargetStock}"
                ])
              ])
            ]) // items
          ])
      ]);
  }

  UI5Element addSuppliersTable() {
    return m.Table([
        "id": "suppliersTable",
        "items": "{/Suppliers}"
      ], [
        m.Element(
          "headerToolbar", [
            m.Toolbar([
              m.Title(
              "{i18n>suppliers}")
            ])
          ]), // headerToolbar
        m.Columns([
          "{i18n>id}",
          "{i18n>name}",
          "{i18n>contactInfo}",
          "{i18n>description}"
        ]),
        m.Element("items", [
            m.ColumnListItem(
            [
              "type": "Active"
            ], [
              m.Element("cells", [
                m.Text(
                "{ID}"),
                m.Text(
                "{Name}"),
                m.Text(
                "{ContactInfo}"),
                m.Text(
                "{Description}")
              ])
            ])
          ])
      ]);
  }

  UI5Element addPlanningTable() {
    return m.Table([
        "id": "plansTable",
        "items": "{/MaterialPlans}"
      ], [
        m.Element("headerToolbar", [
            m.Toolbar([m.Title(
              "{i18n>planning}")])
          ]), // headerToolbar
        m.Columns([
          "{i18n>id}",
          "{i18n>materialId}",
          "{i18n>planningDate}",
          "{i18n>plannedQuantity}"
        ]),
        m.Element("items", [
            m.ColumnListItem([
              "type": "Active"
            ], [
              m.Element("cells", [
                m.Text(
                "{ID}"),
                m.Text(
                "{MaterialID}"),
                m.Text(
                "{PlannedDate}"),
                m.ObjectNumber([
                  "number": "{PlannedQuantity}"
                ])
              ])
            ])
          ])
      ]);
  }

  UI5Element addWarehouseForm() {
    return m.Element("layout:SimpleForm", [
        "editable": "true",
        "layout": "ResponsiveGridLayout",
        "title": "{i18n>assignWarehouse}"
      ],
      [
        m.Element("layout:content", [
            m.Label(
            "{i18n>warehouse}"),
            m.Select(
            [
              "id": "warehouseSelect",
              "items": "{lookup>/warehouses}"
            ], [
              m.Element("core:Item", [
                "key": "{lookup>ID}",
                "text": "{lookup>Name}"
              ])
            ]),
            m.Label(
            "{i18n>storage}"),
            m.Select([
              "id": "assignmentWarehouseSelect",
              "items": "{lookup>/warehouses}"
            ],
            [
              m.Element("core:Item", [
                "key": "{lookup>ID}",
                "text": "{lookup>Name}"
              ])
            ]),
            m.Button([
              "text": "{i18n>saveAssignment}",
              "type": "Emphasized",
              "press": "onCreateAssignment"
            ])
          ])
      ]);
  }

  UI5Element addWarehousesTable() {
    return m.Table([
      "id": "warehousesTable",
      "width": "48%",
      "items": "{/Warehouses}",
      "class": "sapUiSmallMarginEnd"
    ], [
      m.Element("headerToolbar", [
          m.Toolbar([
              m.Title(
              "{i18n>warehouses}")
            ])
        ]),
      m.Columns([
          "{i18n>id}",
          "{i18n>name}",
          "{i18n>location}"
        ]),
      m.Element("items", [
          m.ColumnListItem([
            m.Element("cells", [
                m.Text(
                "{ID}"),
                m.Text(
                "{Name}"),
                m.Text(
                "{Location}")
              ])
          ])
        ])
    ]);
  }

  UI5Element addAssignmentsTable() {
    return m.Table([
      "id": "assignmentsTable",
      "width": "52%",
      "items": "{/WarehouseAssignments}"
    ], [
      m.Element("headerToolbar", [
          m.Toolbar([
              m.Title(
              "{i18n>materialWarehouseAssignment}")
            ])
        ]),
      m.Columns([
          "{i18n>id}",
          "{i18n>materialId}",
          "{i18n>warehouseId}"
        ]),
      m.Element("items", [
          m.ColumnListItem([
            m.Element("cells", [
                m.Text(
                "{ID}"),
                m.Text(
                "{MaterialID}"),
                m.Text(
                "{WarehouseID}")
              ])
          ])
        ])
    ]);
  }

  UI5Element addEvaluationToolbar() {
    return m.Toolbar([
      m.Title(
        "{i18n>stockEvaluation}"),
      m.ToolbarSpacer(),
      m.Button(
        [
          "text": "{i18n>refresh}",
          "press": "onRefreshEvaluations"
        ])
    ]);
  }

  UI5Element addEvaluationsTable() {
    return m.Table([
        "id": "evaluationsTable",
        "items": "{/StockEvaluations}"
      ], [
        m.Columns([
          "{i18n>material}",
          "{i18n>available}",
          "{i18n>target}",
          "{i18n>status}"
        ]),
        m.Element("items", [
            m.ColumnListItem([
              m.Element("cells", [
                m.Text(
                "{MaterialName}"),
                m.ObjectNumber(
                [
                  "number": "{Available}",
                  "unit": "Stk"
                ]),
                m.ObjectNumber(
                [
                  "number": "{TargetStock}",
                  "unit": "Stk"
                ]),
                m.ObjectStatus([
                  "text": "{Status}",
                  "state": "{= ${Status} === 'OK' ? 'Success' : 'Error'}"
                ])
              ])
            ])
          ])
      ]);
  }
}
///
unittest {
  import std.stdio;

  auto view = new AppView(
    "/views/App.view.xml");
  writeln(view.render());
}
