module uim.fiori.landscape.presentation.ui5.views.app;

import uim.fiori.landscape;

@safe:
class AppView : UI5View {
    SAPMLibrary m = new SAPMLibrary();
    // SAPMvcLibrary mvc = new SAPMvcLibrary();
    SAPUxapLibrary uxap = new SAPUxapLibrary();
    SAPSuiteLibrary suite = new SAPSuiteLibrary();
    SAPGraphLibrary graph = new SAPGraphLibrary();
    SAPGanttLibrary gantt = new SAPGanttLibrary();
    SAPCoreLibrary core = new SAPCoreLibrary();

    this(string path) {
        super(path);
        m.prefix = "";

    }

    override UI5Element[] buildView() {
        writeln("AppView:Building view for path: " ~ _path);
        return [
            UI5Element("mvc:View", [
                    "controllerName": "landscape.frontend.controller.App",
                    "xmlns:mvc": "sap.ui.core.mvc",
                    "xmlns:core": "sap.ui.core",
                    "xmlns": "sap.m",
                    "xmlns:uxap": "sap.uxap",
                    "xmlns:graph": "sap.suite.ui.commons.networkgraph",
                    "height": "100%"
                ], [addApp()])
        ];
    }

    UI5Element addApp() {
        return m.App([
                m.Element("pages", [
                        addNavContainer()
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
        return m.Table(["id": "matrixTable", "items": "{/MatrixCells}"], [
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
        return m.Table(["id": "systemsTable", "items": "{/Systems}"], [
                m.Columns([
                    "System", "Bereich", "Prozessebene", "Kritikalitaet",
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
                                m.Text(["text": "{BusinessArea}"]),
                                m.Text(["text": "{ProcessLevel}"]),
                                m.ObjectStatus([
                                    "text": "{Criticality}",
                                    "state": "{ path: 'StatusColor', formatter: '.formatter.toValueState' }"
                                ]),
                                m.Text(["text": "{OperatingModel}"]),
                                m.Text(["text": "{LifecycleStatus}"])
                            ])
                        ])
                    ])
            ]);
    }

    UI5Element addOverviewPage() {
        return m.Page(["id": "overviewPage", "title": "IT-Bebauung Uebersicht"], [
                m.Element("headerContent", [
                        m.Select([
                            "change": ".onLanguageChange",
                            "selectedKey": "{viewModel>/currentLanguage}"
                        ],
                        [
                            core.Item(["key": "en", "text": "English"]),
                            core.Item(["key": "de", "text": "Deutsch"])
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
                                        m.VBox(["class": "sapUiSmallMarginEnd"], [
                                            m.Label(["text": "Kritikalitaet"]),
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
                                        m.VBox(["class": "sapUiSmallMarginEnd"], [
                                            m.Label(["text": "Betriebsart"]),
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
                                        m.VBox(["class": "sapUiSmallMarginEnd"], [
                                            m.Label(["text": "Lebenszyklus"]),
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
                                        m.VBox(["class": "sapUiSmallMarginEnd"], [
                                            m.Label(["text": "Suche"]), // addSearchField([
                                            // "id": "nameSearch",
                                            // "width": "16rem",
                                            // "search": "onApplyFilters"
                                            // ]);
                                        ]),
                                        m.VBox(["justifyContent": "End"], [
                                            m.Button([
                                                "text": "Filter anwenden",
                                                "type": "Emphasized",
                                                "press": "onApplyFilters"
                                            ])
                                        ]),
                                    ]),
                                ]),
                            ]),

                            m.VBox(["class": "landscapeCard"], [
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
                                        m.Title("{detail>/selectedSystem/Name}")
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
                                ], [
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
                                ], [
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
                                ], [
                                    uxap.Element("subSections", [
                                        uxap.ObjectPageSubSection([
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
                                                        graph.Line([
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
