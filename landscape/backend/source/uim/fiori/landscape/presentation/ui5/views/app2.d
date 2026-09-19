module uim.fiori.landscape.presentation.ui5.views.app2;

import uim.fiori.landscape;

@safe:
class App2View : UI5View {
  SAPMLibrary m = new SAPMLibrary();
  // SAPMvcLibrary mvc = new SAPMvcLibrary();
  SAPUxapLibrary uxap = new SAPUxapLibrary();
  SAPSuiteLibrary suite = new SAPSuiteLibrary();
  SAPGraphLibrary graph = new SAPGraphLibrary();
  SAPGanttLibrary gantt = new SAPGanttLibrary();
  SAPCoreLibrary core = new SAPCoreLibrary();
  SAPLayoutLibrary layout = new SAPLayoutLibrary();
  SAPFLibrary f = new SAPFLibrary();
  SAPUIFormLibrary form = new SAPUIFormLibrary();

  this(string path) {
    super(path);
    m.prefix = "";

  }

  override UI5Element[] buildView() {
    writeln("AppView:Building view for path: " ~ _path);
    return [
      UI5Element("mvc:View", [
          "xmlns:core": "sap.ui.core",
          "xmlns:mvc": "sap.ui.core.mvc",
          "xmlns": "sap.m",
          "xmlns:f": "sap.f",
          "xmlns:card": "sap.f.cards",
          "xmlns:layout": "sap.ui.layout",
          "xmlns:grid": "sap.ui.layout.cssgrid",
          "xmlns:uxap": "sap.uxap",
          "xmlns:graph": "sap.suite.ui.commons.networkgraph",
          "xmlns:gantt": "sap.gantt.simple",
          "xmlns:form": "sap.ui.layout.form",
          "height": "100%"
        ], [addLayout()])
    ];
  }

  UI5Element addLayout() {
    return f.FlexibleColumnLayout([
        "id": "fcl",
        "layout": "{viewModel>/layout}"
      ],
      [
        f.Element("beginColumnPages", [
            f.DynamicPage([
              "id": "dynamicPage",
              "headerExpanded": "true",
              "toggleHeaderOnTitleClick": "true"
            ],
            [
              f.Element("title", [
                f.DynamicPageTitle([
                  f.Element("heading", [
                    m.Title([
                      "text": "IT-Bebauungsplan Dashboard",
                      "level": "H2"
                    ])
                  ]),
                  f.Element("actions", [
                    m.Select([
                      "change": ".onLanguageChange",
                      "selectedKey": "{viewModel>/currentLanguage}"
                    ],
                    [
                      core.Item([
                        "key": "en",
                        "text": "English"
                      ]),
                      core.Item([
                        "key": "de",
                        "text": "Deutsch"
                      ])
                    ])
                  ])
                ])
              ]), // title

              f.Element("header", [
                f.DynamicPageHeader(["pinnable": "true"], [
                  m.HBox([
                    "wrap": "Wrap",
                    "justifyContent": "SpaceBetween",
                    "class": "sapUiTinyMarginBottom"
                  ],
                  [
                    m.GenericTile([
                      "header": "Gesamtsysteme",
                      "frameType": "OneByOne",
                      "press": ".onFilterTile",
                      "class": "sapUiTinyMarginEnd"
                    ],
                    [
                      m.TileContent([
                        m.NumericContent([
                          "value": "{/Metrics/TotalSystems}",
                          "icon": "sap-icon://sys-enter-2"
                        ])
                      ])
                    ]),
                    m.GenericTile([
                      "header": "Kritische Systeme",
                      "subheader": "Tier 1",
                      "frameType": "OneByOne",
                      "class": "sapUiTinyMarginEnd"
                    ],
                    [
                      m.TileContent([
                        m.NumericContent([
                          "value": "{/Metrics/Tier1Count}",
                          "valueColor": "Error",
                          "indicator": "Up"
                        ])
                      ])
                    ]),
                    m.GenericTile([
                      "header": "Cloud Anteil",
                      "frameType": "OneByOne",
                      "class": "sapUiTinyMarginEnd"
                    ],
                    [
                      m.TileContent([
                        m.NumericContent([
                          "value": "{/Metrics/CloudRatio}",
                          "scale": "%",
                          "valueColor": "Good"
                        ])
                      ])
                    ])
                  ]), // Filter Bar -->
                  m.Panel([
                    "headerText": "Smart Filter",
                    "expandable": "true",
                    "expanded": "true"
                  ],
                  [
                    layout.HorizontalLayout([
                      "allowWrapping": "true"
                    ],
                    [
                      m.VBox([
                        "class": "sapUiSmallMarginEnd"
                      ],
                      [
                        m.Label([
                          "text": "Kritikalität",
                          "labelFor": "criticalitySelect"
                        ]),
                        m.Select([
                          "id": "criticalitySelect",
                          "selectedKey": "{filters>/criticality}",
                          "width": "11rem"
                        ],
                        [
                          core.Item([
                            "key": "",
                            "text": "Alle"
                          ]),
                          core.Item([
                            "key": "Tier 1",
                            "text": "Tier 1"
                          ]),
                          core.Item([
                            "key": "Tier 2",
                            "text": "Tier 2"
                          ]),
                          core.Item([
                            "key": "Tier 3",
                            "text": "Tier 3"
                          ])
                        ])
                      ]),
                      m.VBox([
                        "class": "sapUiSmallMarginEnd"
                      ],
                      [
                        m.Label([
                          "text": "Betriebsart",
                          "labelFor": "operatingModelSelect"
                        ]),
                        m.Select([
                          "id": "operatingModelSelect",
                          "selectedKey": "{filters>/operatingModel}",
                          "width": "11rem"
                        ],
                        [
                          core.Item([
                            "key": "",
                            "text": "Alle"
                          ]),
                          core.Item([
                            "key": "Cloud",
                            "text": "Cloud"
                          ]),
                          core.Item([
                            "key": "On-Premise",
                            "text": "On-Premise"
                          ])
                        ])
                      ]),
                      m.VBox([
                        "class": "sapUiSmallMarginEnd"
                      ],
                      [
                        m.Label([
                          "text": "Lebenszyklus",
                          "labelFor": "lifecycleSelect"
                        ]),
                        m.Select([
                          "id": "lifecycleSelect",
                          "selectedKey": "{filters>/lifecycleStatus}",
                          "width": "11rem"
                        ],
                        [
                          core.Item([
                            "key": "",
                            "text": "Alle"
                          ]),
                          core.Item([
                            "key": "Active",
                            "text": "Active"
                          ]),
                          core.Item([
                            "key": "Decommissioning",
                            "text": "Decommissioning"
                          ]),
                          core.Item([
                            "key": "Redundant",
                            "text": "Redundant"
                          ])
                        ])
                      ]),
                      m.VBox([
                        "class": "sapUiSmallMarginEnd"
                      ],
                      [
                        m.Label(["text": "System Suche"]),
                        m.SearchField([
                          "width": "14rem",
                          "search": "onSearchSystem"
                        ])
                      ]),
                      m.VBox(["justifyContent": "End"], [
                        m.Button([
                          "type": "Emphasized",
                          "text": "Filter anwenden",
                          "press": "onApplyFilters"
                        ])
                      ])
                    ])
                  ])
                ])
              ]), // Page Main Content -->
              f.Element("content", [
                m.IconTabBar([
                  "id": "idIconTabBar",
                  "expandable": "false",
                  "applyContentPadding": "true"
                ],
                [
                  m.Element("items",
                  [
                    m.IconTabFilter([
                      "icon": "sap-icon://table-chart",
                      "text": "Systemliste"
                    ],
                    [
                      m.Table([
                        "id": "systemsTable",
                        "items": "{/Systems}",
                        "mode": "SingleSelectMaster",
                        "selectionChange": "onOpenSystemDetail"
                      ],
                      [
                        m.Element("columns", [
                          m.Column("System"),
                          m.Column([
                            "demandPopin": "true",
                            "minScreenWidth": "Tablet"
                          ], [m.Text("Bereich")]),
                          m.Column([
                            "demandPopin": "true",
                            "minScreenWidth": "Tablet"
                          ], [m.Text("Prozessebene")]),
                          m.Column("Kritikalität"),
                          m.Column("Betriebsart"),
                          m.Column("Lifecycle")
                        ]),
                        m.Element("items", [
                          m.ColumnListItem([
                            "type": "Navigation",
                            "press": "onOpenSystemDetail"
                          ],
                          [
                            m.Element("cells",
                            [
                              m.ObjectIdentifier([
                                "title": "{Name}",
                                "text": "{ID}"
                              ]),
                              m.Text("{BusinessArea}"),
                              m.Text("{ProcessLevel}"),
                              m.ObjectStatus(
                              [
                                "state": "{path: 'Criticality', formatter: '.formatter.toCriticalityState'}",
                                "text": "{Criticality}"
                              ]),
                              m.Text("{OperatingModel}"),
                              m.ObjectStatus(
                              [
                                "state": "{path: 'LifecycleStatus', formatter: '.formatter.toLifecycleState'}",
                                "text": "{LifecycleStatus}"
                              ])
                            ])
                          ])
                        ])
                      ])
                    ]),

                    m.IconTabFilter([
                      "icon": "sap-icon://grid",
                      "text": "Bebauungs-Matrix"
                    ],
                    [
                      m.Table([
                        "id": "matrixTable",
                        "items": "{/MatrixCells}"
                      ],
                      [
                        m.Element("columns", [
                          m.Column("Geschäftsbereich"),
                          m.Column("Prozessebene"),
                          m.Column("Systeme"),
                          m.Column(["hAlign": "End"], [
                            m.Text(
                            "Anzahl")
                          ])
                        ]),
                        m.Element("items", [
                          m.Element("ColumnListItem", [
                            m.Element("cells", [
                              m.Text("{BusinessArea}"),
                              m.Text("{ProcessLevel}"),
                              m.Text("{Systems}"),
                              m.ObjectNumber(
                              [
                                "number": "{SystemCount}"
                              ])
                            ])
                          ])
                        ])
                      ])
                    ])
                  ])
                ])
              ])
            ])
          ]),

        f.Element("midColumnPages", [
            m.Page([
              "id": "detailPage",
              "showHeader": "true"
            ],
            [
              m.Element("customHeader", [
                m.OverflowToolbar([
                  m.Element("ToolbarSpacer"),
                  m.Element("Button", [
                    "icon": "sap-icon://decline",
                    "type": "Transparent",
                    "press": "onCloseDetailPage"
                  ])
                ])
              ]),
              m.Element("content", [
                uxap.ObjectPageLayout([
                  "id": "objectPageLayout",
                  "showAnchorBar": "true",
                  "isChildPage": "true"
                ],
                [
                  uxap.Element("headerTitle", [
                    uxap.ObjectPageDynamicHeaderTitle([
                      uxap.Element("heading", [
                        m.Title(
                        [
                          "text": "{detail>/selectedSystem/Name}"
                        ])
                      ]),
                      uxap.Element("expandedContent", [
                        m.Label(
                        [
                          "text": "ID: {detail>/selectedSystem/ID}"
                        ])
                      ]),
                      uxap.Element("snappedContent", [
                        m.Label(
                        [
                          "text": "{detail>/selectedSystem/Name}"
                        ])
                      ]),
                      uxap.Element("actions", [
                        m.Button([
                          "text": "Bearbeiten",
                          "type": "Emphasized"
                        ])
                      ])
                    ])
                  ]),

                  uxap.Element("headerContent", [
                    m.FlexBox([
                      "wrap": "Wrap",
                      "fitContainer": "true"
                    ],
                    [
                      m.VBox([
                        "class": "sapUiLargeMarginEnd"
                      ],
                      [
                        m.Label([
                          "text": "Kritikalität"
                        ]),
                        m.ObjectStatus(
                        [
                          "state": "{path: 'detail>/selectedSystem/StatusColor', formatter: '.formatter.toValueState'}",
                          "text": "{detail>/selectedSystem/Criticality}"
                        ])
                      ]),
                      m.VBox([
                        "class": "sapUiLargeMarginEnd"
                      ],
                      [
                        m.Label([
                          "text": "Lifecycle"
                        ]),
                        m.Text(
                        [
                          "text": "{detail>/selectedSystem/LifecycleStatus}"
                        ])
                      ])
                    ]),
                  ]),

                  uxap.Element("sections", [
                    uxap.ObjectPageSection([
                      "title": "Stammdaten"
                    ],
                    [
                      uxap.Element("subSections", [
                        uxap.ObjectPageSubSection(
                        [
                          uxap.Element("blocks", [
                            form.SimpleForm([
                              "editable": "false",
                              "layout": "ColumnLayout"
                            ],
                            [
                              m.Label([
                                "text": "Beschreibung"
                              ]),
                              m.Text(
                              [
                                "text": "{detail>/selectedSystem/Description}"
                              ]),
                              m.Label([
                                "text": "Business Area"
                              ]),
                              m.Text(
                              [
                                "text": "{detail>/selectedSystem/BusinessArea}"
                              ]),
                              m.Label([
                                "text": "Process Level"
                              ]),
                              m.Text(
                              [
                                "text": "{detail>/selectedSystem/ProcessLevel}"
                              ]),
                              m.Label([
                                "text": "Operating Model"
                              ]),
                              m.Text(
                              [
                                "text": "{detail>/selectedSystem/OperatingModel}"
                              ])
                            ])
                          ]),
                        ]),
                      ]),
                    ]),

                    uxap.ObjectPageSection([
                      "title": "Verantwortliche Personen"
                    ],
                    [
                      uxap.Element("subSections", [
                        uxap.ObjectPageSubSection(
                        [
                          uxap.Element("blocks", [
                            form.SimpleForm([
                              "editable": "false",
                              "layout": "ColumnLayout"
                            ],
                            [
                              m.Label([
                                "text": "Business Owner"
                              ]),
                              m.Text(
                              "{detail>/selectedSystem/BusinessOwner}"),
                              m.Label([
                                "text": "IT Owner"
                              ]),
                              m.Text(
                              "{detail>/selectedSystem/ITOwner}")
                            ])
                          ]),
                        ]),
                      ]),
                    ]),

                    uxap.ObjectPageSection([
                      "title": "Schnittstellen-Netzwerk"
                    ],
                    [
                      uxap.Element("subSections", [
                        uxap.ObjectPageSubSection(
                        [
                          uxap.Element("blocks", [
                            m.VBox([
                              "height": "400px"
                            ],
                            [
                              graph.Graph(
                              [
                                "id": "interfaceGraph",
                                "orientation": "LeftRight",
                                "nodes": "{detail>/graphNodes}",
                                "lines": "{detail>/graphLines}"
                              ],
                              [
                                graph.Element("nodes", [
                                  graph.Node([
                                    "key": "{detail>key}",
                                    "title": "{detail>title}",
                                    "status": "{detail>status}"
                                  ])
                                ]),
                                graph.Element("lines", [
                                  graph.Line([
                                    "to": "{detail>to}",
                                    "from": "{detail>from}",
                                    "title": "{detail>title}"
                                  ])
                                ])
                              ])
                            ])
                          ])
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

  UI5Element addNavContainer() {
    return m.NavContainer([
        "id": "navContainer",
        "initialPage": "overviewPage"
      ], [
        m.Element("pages", [
            addOverviewPage(),
            addDetailPage()
          ])
      ]);
  }

  UI5Element addMatrixCellsTable() {
    return m.Table([
        "id": "matrixTable",
        "items": "{/MatrixCells}"
      ], [
        m.Columns([
            "Geschaeftsbereich",
            "Prozessebene",
            "Systeme",
            "Anzahl"
          ]),
        m.Element("items", [
            m.ColumnListItem([
              m.Element("cells", [
                m.Text("{BusinessArea}"),
                m.Text("{ProcessLevel}"),
                m.Text("{Systems}"),
                m.ObjectNumber([
                  "number": "{SystemCount}"
                ])
              ])
            ])
          ])
      ]);
  }

  UI5Element addSystemsTable() {
    return m.Table([
        "id": "systemsTable",
        "items": "{/Systems}"
      ], [
        m.Columns([
          "System", "Bereich",
          "Prozessebene",
          "Kritikalitaet",
          "Betriebsart", "Lifecycle"
        ]),
        m.Element("items", [
            m.ColumnListItem([
              "type": "Active",
              "press": "onOpenSystemDetail"
            ],
            [
              m.Element("cells", [
                m.ObjectIdentifier([
                  "title": "{Name}",
                  "text": "{ID}"
                ]),
                m.Text([
                  "text": "{BusinessArea}"
                ]),
                m.Text([
                  "text": "{ProcessLevel}"
                ]),
                m.ObjectStatus([
                  "text": "{Criticality}",
                  "state": "{ path: 'StatusColor', formatter: '.formatter.toValueState' }"
                ]),
                m.Text([
                  "text": "{OperatingModel}"
                ]),
                m.Text([
                  "text": "{LifecycleStatus}"
                ])
              ])
            ])
          ])
      ]);
  }

  UI5Element addOverviewPage() {
    return m.Page([
        "id": "overviewPage",
        "title": "IT-Bebauung Uebersicht"
      ], [
        m.Element("headerContent", [
            m.Select([
              "change": ".onLanguageChange",
              "selectedKey": "{viewModel>/currentLanguage}"
            ],
            [
              core.Item([
                "key": "en",
                "text": "English"
              ]),
              core.Item([
                "key": "de",
                "text": "Deutsch"
              ])
            ])
          ]),
        m.Element("content", [
            m.VBox([
              "class": "sapUiSmallMargin",
              "renderType": "Bare"
            ],
            [
              m.Title([
                "text": "Application Landscape Map",
                "level": "H2"
              ]),
              m.HBox([
                "renderType": "Bare",
                "justifyContent": "SpaceBetween",
                "wrap": "Wrap"
              ],
              [
                m.VBox([
                  "width": "100%",
                  "class": "landscapeCard sapUiSmallMarginBottom"
                ],
                [
                  m.Title([
                    "text": "Kachel 1: Karten-Ansicht",
                    "level": "H4"
                  ]),
                  addMatrixCellsTable()
                ])
              ]),
              m.HBox([
                "renderType": "Bare",
                "justifyContent": "SpaceBetween",
                "wrap": "Wrap"
              ],
              [
                m.VBox([
                  "width": "49%",
                  "class": "landscapeCard sapUiSmallMarginBottom"
                ],
                [
                  m.Title([
                    "text": "Kachel 2: Smart Filter Bar",
                    "level": "H4"
                  ]),
                  m.HBox([
                    "renderType": "Bare",
                    "wrap": "Wrap"
                  ],
                  [
                    m.VBox([
                      "class": "sapUiSmallMarginEnd"
                    ],
                    [
                      m.Label([
                        "text": "Kritikalitaet"
                      ]),
                      m.Select([
                        "id": "criticalitySelect",
                        "width": "12rem",
                        "selectedKey": "{filters>/criticality}"
                      ],
                      [
                        core.Item([
                          "key": "",
                          "text": "Alle"
                        ]),
                        core.Item([
                          "key": "Tier 1",
                          "text": "Tier 1"
                        ]),
                        core.Item([
                          "key": "Tier 2",
                          "text": "Tier 2"
                        ]),
                        core.Item([
                          "key": "Tier 3",
                          "text": "Tier 3"
                        ])
                      ]),
                    ]),
                    m.VBox([
                      "class": "sapUiSmallMarginEnd"
                    ],
                    [
                      m.Label([
                        "text": "Betriebsart"
                      ]),
                      m.Select([
                        "id": "operatingModelSelect",
                        "width": "12rem",
                        "selectedKey": "{filters>/operatingModel}"
                      ],
                      [
                        core.Item([
                          "key": "",
                          "text": "Alle"
                        ]),
                        core.Item([
                          "key": "Cloud",
                          "text": "Cloud"
                        ]),
                        core.Item([
                          "key": "On-Premise",
                          "text": "On-Premise"
                        ])
                      ]),
                    ]),
                    m.VBox([
                      "class": "sapUiSmallMarginEnd"
                    ],
                    [
                      m.Label([
                        "text": "Lebenszyklus"
                      ]),
                      m.Select([
                        "id": "lifecycleSelect",
                        "width": "14rem",
                        "selectedKey": "{filters>/lifecycleStatus}"
                      ],
                      [
                        core.Item([
                          "key": "",
                          "text": "Alle"
                        ]),
                        core.Item([
                          "key": "Active",
                          "text": "Active"
                        ]),
                        core.Item([
                          "key": "Decommissioning",
                          "text": "Decommissioning"
                        ]),
                        core.Item([
                          "key": "Redundant",
                          "text": "Redundant"
                        ])
                      ]),
                    ]),
                    m.VBox([
                      "class": "sapUiSmallMarginEnd"
                    ],
                    [
                      m.Label(
                      [
                        "text": "Suche"
                      ]), // addSearchField([
                      // "id": "nameSearch",
                      // "width": "16rem",
                      // "search": "onApplyFilters"
                      // ]);

                    ]),
                    m.VBox([
                      "justifyContent": "End"
                    ],
                    [
                      m.Button([
                        "text": "Filter anwenden",
                        "type": "Emphasized",
                        "press": "onApplyFilters"
                      ])
                    ]),
                  ]),
                ]),
              ]),

              m.VBox([
                "class": "landscapeCard"
              ],
              [
                m.Title([
                  "text": "Systemliste",
                  "level": "H4"
                ]),
                addSystemsTable()
              ])
            ])
          ])
      ]);
  }

  UI5Element addDetailPage() {
    return m.Page([
      "id": "detailPage",
      "title": "System-Detail",
      "showNavButton": "true",
      "navButtonPress": "onBackToOverview"
    ], [
      m.Element("content", [
          uxap.ObjectPageLayout([
            "id": "objectPageLayout",
            "showAnchorBar": "false"
          ],
          [
            uxap.Element("headerTitle", [
                uxap.Element("ObjectPageDynamicHeaderTitle", [
                  uxap.Element("heading", [
                    m.Title(
                    "{detail>/selectedSystem/Name}")
                  ]),
                  uxap.Element("content", [
                    m.ObjectStatus([
                      "text": "{detail>/selectedSystem/Criticality}",
                      "state": "{ path: 'detail>/selectedSystem/StatusColor', formatter: '.formatter.toValueState' }"
                    ]),
                    m.Text(
                    "Lifecycle: {detail>/selectedSystem/LifecycleStatus}")
                  ])
                ])
              ]),
            uxap.Element("sections", [
                uxap.ObjectPageSection([
                  "title": "Stammdaten"
                ],
                [
                  uxap.Element("subSections", [
                    uxap.ObjectPageSubSection(
                    [
                      uxap.Element("blocks", [
                        m.VBox(
                        [
                          m.Text(
                          "{detail>/selectedSystem/Description}"),
                          m.Text(
                          "Business Area: {detail>/selectedSystem/BusinessArea}"),
                          m.Text(
                          "Process Level: {detail>/selectedSystem/ProcessLevel}"),
                          m.Text(
                          "Operating Model: {detail>/selectedSystem/OperatingModel}")
                        ])
                      ])
                    ])
                  ])
                ]),
                uxap.ObjectPageSection(
                [
                  "title": "Verantwortliche Personen"
                ],
                [
                  uxap.Element("subSections", [
                    uxap.ObjectPageSubSection([
                      uxap.Element("blocks", [
                        m.VBox(
                        [
                          m.Text(
                          "Business Owner: {detail>/selectedSystem/BusinessOwner}"),
                          m.Text(
                          "IT Owner: {detail>/selectedSystem/ITOwner}")
                        ])
                      ])
                    ])
                  ])
                ]),
                uxap.ObjectPageSection(
                [
                  "title": "Schnittstellen-Netzwerk"
                ],
                [
                  uxap.Element("subSections", [
                    uxap.ObjectPageSubSection(
                    [
                      uxap.Element("blocks", [
                        graph.Graph(
                        [
                          "id": "interfaceGraph",
                          "orientation": "LeftRight",
                          "nodes": "{detail>/graphNodes}",
                          "lines": "{detail>/graphLines}"
                        ],
                        [
                          graph.Element("nodes",
                          [
                            graph.Node(
                            [
                              "key": "{detail>key}",
                              "title": "{detail>title}",
                              "status": "{detail>status}"
                            ]),
                          ]
                          ),
                          graph.Element("lines",
                          [
                            graph.Line(
                            [
                              "from": "{detail>from}",
                              "to": "{detail>to}",
                              "title": "{detail>title}"
                            ])
                          ])
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

}
