module uim.fiori_project.presentation.ui5.views.app;

import uim.fiori_project;
import uim.xml;

@safe:
class AppView : MvcView {
    SAPMLibrary m = new SAPMLibrary();
    SAPMicrochartLibrary micro = new SAPMicrochartLibrary();
    SAPCommonsLibrary commons = new SAPCommonsLibrary();
    SAPGanttLibrary gantt = new SAPGanttLibrary();
    SAPSuiteLibrary suite = new SAPSuiteLibrary();
    SAPGraphLibrary graph = new SAPGraphLibrary();

    this() {
        super();
    }

    this(Json initData) {
        super(initData);
    }

    this(string customPath, Json initData = Json.emptyObject) {
        super(customPath, initData);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        m.prefix = "";
        _controllerName = "pm.fiori.controller.App";
        _libs = [
            "xmlns:mvc": "sap.ui.core.mvc",
            "xmlns": "sap.m",
            "xmlns:layout": "sap.ui.layout",
            "xmlns:micro": "sap.suite.ui.microchart",
            "xmlns:commons": "sap.suite.ui.commons",
            "xmlns:graph": "sap.suite.ui.commons.networkgraph",
            "xmlns:gantt": "sap.gantt.control",
            "xmlns:ax": "sap.gantt.axistime",
            "xmlns:config": "sap.gantt.config",
            "xmlns:shape": "sap.gantt.shape",
            "xmlns:table": "sap.ui.table"
        ];

        return true;
    }

    override protected UI5Element[] buildView() {
        writeln("AppView:Building view for path: " ~ _path);
        _libs["height"] = "100%";
        _libs["controllerName"] = _controllerName;
        return [
            UI5Element("mvc:View", _libs, [DashboardPage()])
        ];
    }

    UI5Element DashboardPage() {
        return m.Page([
            "title": "Projektmanagement Dashboard",
            "class": "sapUiContentPadding"
        ], [
            m.Element("content", [
                    m.IconTabBar([
                        "id": "idIconTabBar",
                        "class": "sapUiResponsiveContentPadding"
                    ],
                    [
                        m.Element("items", [
                                m.IconTabFilter([
                                    "text": "Übersicht - Status",
                                    "icon": "sap-icon://hint"
                                ],
                                [
                                    m.VBox([
                                        addKPIPanel(),
                                        addProcessflowPanel()
                                    ])
                                ]),
                                m.IconTabFilter([
                                    "text": "System-Abhängigkeiten",
                                    "icon": "sap-icon://connected" // ],
                                    // [
                                    // DashboardPage:addArchitecturePanel(); 

                                

                            ]),
                        m.IconTabFilter([
                            "text": "Gantt Terminplanung",
                            "icon": "sap-icon://gantt-chart" // ],
                            // [
                            // addGanttChartPanel();

                        

                    ])
                ])
        ])])]);
    }

    UI5Element addKPIPanel() {
        return m.Panel([
            "headerText": "KPI Key Metrics (MicroCharts)",
            "expandable": "true",
            "expanded": "true",
            "class": "sapUiMediumMarginBottom"
        ], [
            m.HBox(["class": "sapUiSmallMarginBottom"], [
                    m.VBox(["class": "sapUiMediumMarginEnd"], [
                            m.Label(["text": "Projekt-Fortschritt (%)"]),
                            micro.RadialMicroChart([
                                "percentage": "{pmModel>/metrics/actualPercent}",
                                "valueColor": "Good",
                                "size": "M"
                            ])
                        ]),
                    m.VBox([
                        m.Label([
                                "text": "Budget-Ausschöpfung (€)"
                            ]),
                        micro.BulletMicroChart([
                            "targetValue": "{pmModel>/metrics/budgetTotal}",
                            "actualValueLabel": "420k",
                            "targetValueLabel": "550k",
                            "size": "M"
                        ],
                        [
                            micro.Element("actual", [
                                    micro.BulletMicroChartData([
                                        "value": "{pmModel>/metrics/budgetSpent}",
                                        "color": "Critical"
                                    ])
                                ]),
                            micro.Element("thresholds", [
                                    micro.BulletMicroChartData([
                                        "value": "0",
                                        "color": "Good"
                                    ]),
                                    micro.BulletMicroChartData([
                                        "value": "400000",
                                        "color": "Critical"
                                    ]),
                                    micro.BulletMicroChartData([
                                        "value": "550000",
                                        "color": "Error"
                                    ])
                                ])
                        ])
                    ])
                ])
        ]);
    }

    UI5Element addProcessflowPanel() {
        return m.Panel([
            "headerText": "Prozess-Gateways (ProcessFlow)",
            "expandable": "true",
            "expanded": "true"
        ], [
            commons.ProcessFlow([
                "id": "processFlow",
                "scrollable": "true",
                "nodes": "{pmModel>/processFlow/nodes}",
                "lanes": "{pmModel>/processFlow/lanes}"
            ],
            [
                commons.Element("nodes", [
                        commons.ProcessFlowNode([
                            "nodeId": "{pmModel>id}",
                            "laneId": "{pmModel>laneId}",
                            "title": "{pmModel>title}",
                            "state": "{pmModel>state}",
                            "children": "{pmModel>children}"
                        ]),
                    ]),
                commons.Element("lanes", [
                        commons.ProcessFlowLaneHeader([
                            "laneId": "{pmModel>id}",
                            "iconSrc": "{pmModel>icon}",
                            "text": "{pmModel>label}",
                            "position": "{pmModel>position}"
                        ])
                    ])
            ])
        ]);
    }

    UI5Element addArchitecturePanel() {
        return m.Panel([
            "headerText": "Architektur &amp; Modul-Netzplan",
            "height": "600px"
        ], [
            graph.Graph([
                "id": "networkGraph",
                "nodes": "{pmModel>/networkGraph/nodes}",
                "lines": "{pmModel>/networkGraph/lines}"
            ],
            [
                graph.Element("nodes", [
                        graph.Node([
                            "key": "{pmModel>key}",
                            "title": "{pmModel>title}",
                            "group": "{pmModel>group}",
                            "status": "{pmModel>status}"
                        ])
                    ]),
                graph.Element("lines", [
                        graph.Line([
                            "from": "{pmModel>from}",
                            "to": "{pmModel>to}",
                            "status": "{pmModel>status}"
                        ])
                    ])
            ])
        ]);
    }

    UI5Element addGanttChartPanel() {
        return m.Panel([
            "headerText": "Zeitliche Ablaufplanung",
            "height": "650px"
        ]); // , {
        //     addGanttChartWithTable([
        //             "id": "ganttChart",
        //             "ghostAlignment": "Start"
        //         ],  {
        //         addElement("gantt:axisTimeStrategy",  {
        //             addProportionalTimeStrategy([
        //                 addElement("ax:totalHorizon", [
        //                     addElement("config:TimeHorizon", [
        //                         "startTime": "20260915000000",
        //                         "endTime": "20261231000000"
        //                     ])
        //                     }),
        //                     addElement("ax:visibleHorizon",  {
        //                         addElement("config:TimeHorizon", [
        //                             "startTime": "20261001000000",
        //                             "endTime": "20261130000000"
        //                         ])
        //                     })
        //                     })}),
        //                     addElement("gantt:table", {
        //                         addElement("table:TreeTable", [
        //                             "rows": "{
        //                             path: 'pmModel>/ganttOrders',
        //                             parameters: {arrayNames: ['tasks']}
        //                             }",
        //                             "selectionMode": "Single"
        //                         ], {
        //                             addElement("table:columns", {
        //                                 addElement("table:Column", [
        //                                     "width": "200px",
        //                                     "label": "Aufgabe/Phase"
        //                                 ], {
        //                                     addElement("table:template", {
        //                                         addLabel(
        //                                         [
        //                                             "text": "{pmModel>name}"
        //                                         ]);
        //                                     });
        //                                 });
        //                             });
        //                             addElement("table:TreeTable");
        //                         });
        //                     }); addElement("gantt:shapes", null, {
        //                         addElement("shape:Task", [
        //                             "time": "{pmModel>startTime}",
        //                             "endTime": "{pmModel>endTime}",
        //                             "title": "{pmModel>name}",
        //                             "type": "Normal"
        //                         ]);
        //                     });}

        //                     );}

        // );
    }
}
