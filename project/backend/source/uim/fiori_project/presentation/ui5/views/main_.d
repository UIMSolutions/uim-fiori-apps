module uim.fiori_project.presentation.ui5.views.main_;

import uim.fiori_project;
import uim.xml;

@safe:
class PMMainView : MainView {
    this() {
        super();
    }

    this(Json initData) {
        super(initData);
    }

    this(string customPath, Json initData = Json(null)) {
        super(customPath, initData);
    }

    override bool initialize(Json initData = Json(null)) {
        if (!super.initialize(initData))
            return false;

        _controllerName = "pm.fiori.controller.Main";
        _libs = [
            "xmlns:mvc": "sap.ui.core.mvc",
            "xmlns": "sap.m",
            "xmlns:layout": "sap.ui.layout",
            "xmlns:micro": "sap.suite.ui.microchart",
            "xmlns:pf": "sap.suite.ui.commons",
            "xmlns:graph": "sap.suite.ui.commons.networkgraph",
            "xmlns:gantt": "sap.gantt.control",
            "xmlns:ax": "sap.gantt.axistime",
            "xmlns:config": "sap.gantt.config",
            "xmlns:shape": "sap.gantt.shape",
            "xmlns:table": "sap.ui.table"
        ];

        return true;
    }

    override protected void buildView() {
        // super.buildView();
        auto attributes = _libs.dup;
        attributes["controllerName"] = _controllerName;
        attributes["height"] = _height;
        _writer.addElement("mvc:View")
            .addAttributes(attributes);
        _writer.endElement();
    }

    void DashboardPage() {
        addPage([
            "title": "Projektmanagement Dashboard",
            "class": "sapUiContentPadding"
        ], {
            addElement("content", null, {
                addIconTabBar([
                    "id": "idIconTabBar",
                    "class": "sapUiResponsiveContentPadding"
                ], {
                    addElement("items", null, {
                        addIconTabFilter([
                            "text": "Übersicht - Status",
                            "icon": "sap-icon://hint"
                        ], {
                            addVBox(null, {
                                addKPIPanel();
                                addProcessflowPanel();
                            });
                        });
                        addIconTabFilter([
                            "text": "System-Abhängigkeiten",
                            "icon": "sap-icon://connected"
                        ], { addArchitecturePanel(); });
                        addIconTabFilter([
                            "text": "Gantt Terminplanung",
                            "icon": "sap-icon://gantt-chart"
                        ], {
                            // addGanttChartPanel();
                        });
                    });
                });
            });
        });
    }

    void addKPIPanel() {
        addPanel([
            "headerText": "KPI Key Metrics (MicroCharts)",
            "expandable": "true",
            "expanded": "true",
            "class": "sapUiMediumMarginBottom"
        ], {
            addHBox(["class": "sapUiSmallMarginBottom"], {
                addVBox(["class": "sapUiMediumMarginEnd"], {
                    addLabel(["text": "Projekt-Fortschritt (%)"]);
                    addRadialMicroChart([
                        "percentage": "{pmModel>/metrics/actualPercent}",
                        "valueColor": "Good",
                        "size": "M"
                    ]);
                });
                addVBox({
                    addLabel(["text": "Budget-Ausschöpfung (€)"]);
                    addBulletMicroChart([
                        "targetValue": "{pmModel>/metrics/budgetTotal}",
                        "actualValueLabel": "420k",
                        "targetValueLabel": "550k",
                        "size": "M"
                    ], {
                        addElement("micro:actual", {
                            addBulletMicroChartData([
                                "value": "{pmModel>/metrics/budgetSpent}",
                                "color": "Critical"
                            ]);
                        });
                        addElement("micro:thresholds", {
                            addBulletMicroChartData([
                                "value": "0",
                                "color": "Good"
                            ]);
                            addBulletMicroChartData([
                                "value": "400000",
                                "color": "Critical"
                            ]);
                            addBulletMicroChartData([
                                "value": "550000",
                                "color": "Error"
                            ]);
                        });
                    });
                });
            });
        });
    }

    void addProcessflowPanel() {
        addPanel([
            "headerText": "Prozess-Gateways (ProcessFlow)",
            "expandable": "true",
            "expanded": "true"
        ], {
            addProcessFlow([
                "id": "processFlow",
                "scrollable": "true",
                "nodes": "{pmModel>/processFlow/nodes}",
                "lanes": "{pmModel>/processFlow/lanes}"
            ], {
                addElement("pf:nodes", {
                    addProcessFlowNode([
                        "nodeId": "{pmModel>id}",
                        "laneId": "{pmModel>laneId}",
                        "title": "{pmModel>title}",
                        "state": "{pmModel>state}",
                        "children": "{pmModel>children}"
                    ]);
                });
                addElement("pf:lanes", {
                    addProcessFlowLaneHeader([
                        "laneId": "{pmModel>id}",
                        "iconSrc": "{pmModel>icon}",
                        "text": "{pmModel>label}",
                        "position": "{pmModel>position}"
                    ]);
                });
            });
        });
    }

    void addArchitecturePanel() {
        addPanel([
            "headerText": "Architektur &amp; Modul-Netzplan",
            "height": "600px"
        ], {
            addNetworkGraph([
                "id": "networkGraph",
                "nodes": "{pmModel>/networkGraph/nodes}",
                "lines": "{pmModel>/networkGraph/lines}"
            ], {
                addElement("graph:nodes", null, {
                    addElement("graph:Node", [
                            "key": "{pmModel>key}",
                            "title": "{pmModel>title}",
                            "group": "{pmModel>group}",
                            "status": "{pmModel>status}"
                        ]);
                });
                addElement("graph:lines", null, {
                    addElement("graph:Line", [
                            "from": "{pmModel>from}",
                            "to": "{pmModel>to}",
                            "status": "{pmModel>status}"
                        ]);
                });
            });
        });
    }

    void addGanttChartPanel() {
        addPanel(["headerText": "Zeitliche Ablaufplanung", "height": "650px"], {
            addGanttChartWithTable([
                "id": "ganttChart",
                "ghostAlignment": "Start"
            ], {
                addElement("gantt:axisTimeStrategy", {
                    addProportionalTimeStrategy(null, {
                        addElement("ax:totalHorizon", {
                            addElement("config:TimeHorizon", [
                                "startTime": "20260915000000",
                                "endTime": "20261231000000"
                            ]);
                        });
                        addElement("ax:visibleHorizon", {
                            addElement("config:TimeHorizon", [
                                "startTime": "20261001000000",
                                "endTime": "20261130000000"
                            ]);
                        });
                    });
                });
                addElement("gantt:table", {
                    addElement("table:TreeTable", [
                        "rows": "{
                                    path: 'pmModel>/ganttOrders',
                                    parameters: {arrayNames: ['tasks']}
                                    }",
                        "selectionMode": "Single"
                    ], {
                        addElement("table:columns", {
                            addElement("table:Column", [
                                "width": "200px",
                                "label": "Aufgabe/Phase"
                            ], {
                                addElement("table:template", {
                                    addLabel(["text": "{pmModel>name}"]);
                                });
                            });
                        });
                        addElement("table:TreeTable");
                    });
                });
                addElement("gantt:shapes", null, {
                    addElement("shape:Task", [
                        "time": "{pmModel>startTime}",
                        "endTime": "{pmModel>endTime}",
                        "title": "{pmModel>name}",
                        "type": "Normal"
                    ]);
                });
            });
        });
    }
}
