module uim.fiori.landscape.presentation.ui5.views.app;
import uim.fiori.landscape;

@safe:
class AppView : UI5View {
    SAPMLibrary m = new SAPMLibrary();
    SAPMvcLibrary mvc = new SAPMvcLibrary();
    SAPUxapLibrary uxap = new SAPUxapLibrary();
    SAPSuiteLibrary suite = new SAPSuiteLibrary();
    SAPGraphLibrary graph = new SAPGraphLibrary();
    SAPGanttLibrary gantt = new SAPGanttLibrary();

    this(string path) {
        super(path);
    }

    override UI5Element[] buildView() {
        _writer.addElement("mvc:View")
            .addAttributes([
                "controllerName": "landscape.frontend.controller.App",
                "xmlns:mvc": "sap.ui.core.mvc",
                "xmlns:core": "sap.ui.core",
                "xmlns": "sap.m",
                "xmlns:uxap": "sap.uxap",
                "xmlns:network": "sap.suite.ui.commons.networkgraph",
                "height": "100%"
            ]);
        // addNavContainer();
        addApp();
        _writer.endElement();
    }

    override void addApp(string[string] values = null, scope void delegate() @safe content = null) {
        super.addApp(values, { addElement("pages", null, { addNavContainer(); }); });
    }

    void addNavContainer() {
        addElement("NavContainer", [
                "id": "navContainer",
                "initialPage": "overviewPage"
            ], {
            addElement("pages", null, { addOverviewPage(); addDetailPage(); });
        });
    }

    void addMatrixCellsTable() {
        addTable(["id": "matrixTable", "items": "{/MatrixCells}"], {
            addColumns([
                "Geschaeftsbereich",
                "Prozessebene",
                "Systeme",
                "Anzahl"
            ]);
            addElement("items", null, {
                addElement("ColumnListItem", null, {
                    addElement("cells", null, {
                        addText("{BusinessArea}");
                        addText("{ProcessLevel}");
                        addText("{Systems}");
                        addObjectNumber(["number": "{SystemCount}"]);
                    });
                });
            });
        });
    }

    void addSystemsTable() {
        addTable(["id": "systemsTable", "items": "{/Systems}"], {
            addColumns([
                "System", "Bereich", "Prozessebene", "Kritikalitaet",
                "Betriebsart", "Lifecycle"
            ]);
            addElement("items", null, {
                addColumnListItem([
                    "type": "Active",
                    "press": "onOpenSystemDetail"
                ], {
                    addCells(null, {
                        addObjectIdentifier(["title": "{Name}", "text": "{ID}"]);
                        addText(["text": "{BusinessArea}"]);
                        addText(["text": "{ProcessLevel}"]);
                        addObjectStatus([
                            "text": "{Criticality}",
                            "state": "{ path: 'StatusColor', formatter: '.formatter.toValueState' }"
                        ]);
                        addText(["text": "{OperatingModel}"]);
                        addText(["text": "{LifecycleStatus}"]);
                    });
                });
            });
        });
    }

    void addOverviewPage() {
        addPage(["id": "overviewPage", "title": "IT-Bebauung Uebersicht"], {
            addElement("headerContent", null, {
                addSelect([
                    "change": ".onLanguageChange",
                    "selectedKey": "{viewModel>/currentLanguage}"
                ], {
                    addCoreItem(["key": "en", "text": "English"]);
                    addCoreItem(["key": "de", "text": "Deutsch"]);
                });
            });
            addElement("content", null, {
                addVBox(["class": "sapUiSmallMargin", "renderType": "Bare"], {
                    addTitle([
                        "text": "Application Landscape Map",
                        "level": "H2"
                    ]);
                    addHBox([
                        "renderType": "Bare",
                        "justifyContent": "SpaceBetween",
                        "wrap": "Wrap"
                    ], {
                        addVBox([
                            "width": "100%",
                            "class": "landscapeCard sapUiSmallMarginBottom"
                        ], {
                            addTitle([
                                "text": "Kachel 1: Karten-Ansicht",
                                "level": "H4"
                            ]);
                            addMatrixCellsTable();
                        });
                    });
                    addHBox([
                        "renderType": "Bare",
                        "justifyContent": "SpaceBetween",
                        "wrap": "Wrap"
                    ], {
                        addVBox([
                            "width": "49%",
                            "class": "landscapeCard sapUiSmallMarginBottom"
                        ], {
                            addTitle([
                                "text": "Kachel 2: Smart Filter Bar",
                                "level": "H4"
                            ]);
                            addHBox(["renderType": "Bare", "wrap": "Wrap"], {
                                addVBox(["class": "sapUiSmallMarginEnd"], {
                                    addLabel(["text": "Kritikalitaet"]);
                                    addSelect([
                                        "id": "criticalitySelect",
                                        "width": "12rem",
                                        "selectedKey": "{filters>/criticality}"
                                    ], {
                                        addCoreItem([
                                            "key": "",
                                            "text": "Alle"
                                        ]);
                                        addCoreItem([
                                            "key": "Tier 1",
                                            "text": "Tier 1"
                                        ]);
                                        addCoreItem([
                                            "key": "Tier 2",
                                            "text": "Tier 2"
                                        ]);
                                        addCoreItem([
                                            "key": "Tier 3",
                                            "text": "Tier 3"
                                        ]);
                                    });
                                });
                                addVBox(["class": "sapUiSmallMarginEnd"], {
                                    addLabel(["text": "Betriebsart"]);
                                    addSelect([
                                        "id": "operatingModelSelect",
                                        "width": "12rem",
                                        "selectedKey": "{filters>/operatingModel}"
                                    ], {
                                        addCoreItem([
                                            "key": "",
                                            "text": "Alle"
                                        ]);
                                        addCoreItem([
                                            "key": "Cloud",
                                            "text": "Cloud"
                                        ]);
                                        addCoreItem([
                                            "key": "On-Premise",
                                            "text": "On-Premise"
                                        ]);
                                    });
                                });
                                addVBox(["class": "sapUiSmallMarginEnd"], {
                                    addLabel(["text": "Lebenszyklus"]);
                                    addSelect([
                                        "id": "lifecycleSelect",
                                        "width": "14rem",
                                        "selectedKey": "{filters>/lifecycleStatus}"
                                    ], {
                                        addCoreItem([
                                            "key": "",
                                            "text": "Alle"
                                        ]);
                                        addCoreItem([
                                            "key": "Active",
                                            "text": "Active"
                                        ]);
                                        addCoreItem([
                                            "key": "Decommissioning",
                                            "text": "Decommissioning"
                                        ]);
                                        addCoreItem([
                                            "key": "Redundant",
                                            "text": "Redundant"
                                        ]);
                                    });
                                });
                                addVBox(["class": "sapUiSmallMarginEnd"], {
                                    addLabel(["text": "Suche"]);
                                    // addSearchField([
                                    // "id": "nameSearch",
                                    // "width": "16rem",
                                    // "search": "onApplyFilters"
                                    // ]);
                                });
                                addVBox(["justifyContent": "End"], {
                                    addButton([
                                        "text": "Filter anwenden",
                                        "type": "Emphasized",
                                        "press": "onApplyFilters"
                                    ]);
                                });
                            });
                        });
                    });

                    addVBox(["class": "landscapeCard"], {
                        addTitle([
                            "text": "Systemliste",
                            "level": "H4"
                        ]);
                        addSystemsTable();
                    });
                });
            });
        });
    }

    void addDetailPage() {
        addPage([
            "id": "detailPage",
            "title": "System-Detail",
            "showNavButton": "true",
            "navButtonPress": "onBackToOverview"
        ], {
            addElement("content", null, {
                addObjectPageLayout([
                    "id": "objectPageLayout",
                    "showAnchorBar": "false"
                ], {
                    addElement("uxap:headerTitle", null, {
                        addElement("uxap:ObjectPageDynamicHeaderTitle", null, {
                            addElement("uxap:heading", null, {
                                addTitle("{detail>/selectedSystem/Name}");
                            });
                            addElement("uxap:content", null, {
                                addObjectStatus([
                                    "text": "{detail>/selectedSystem/Criticality}",
                                    "state": "{ path: 'detail>/selectedSystem/StatusColor', formatter: '.formatter.toValueState' }"
                                ]);
                                addText(
                                "Lifecycle: {detail>/selectedSystem/LifecycleStatus}");
                            });
                        });
                    });
                    addElement("uxap:sections", null, {
                        addObjectPageSection([
                            "title": "Stammdaten"
                        ], {
                            addElement("uxap:subSections", null, {
                                addObjectPageSubSection(null, {
                                    addElement("uxap:blocks", null, {
                                        addVBox(null, {
                                            addText(
                                            "{detail>/selectedSystem/Description}");
                                            addText(
                                            "Business Area: {detail>/selectedSystem/BusinessArea}");
                                            addText(
                                            "Process Level: {detail>/selectedSystem/ProcessLevel}");
                                            addText(
                                            "Operating Model: {detail>/selectedSystem/OperatingModel}");
                                        });
                                    });
                                });
                            });
                        });
                        addObjectPageSection(
                        [
                            "title": "Verantwortliche Personen"
                        ], {
                            addObjectPageSubSections(null, {
                                addObjectPageSubSection(null, {
                                    addElement("uxap:blocks", null, {
                                        addVBox(null, {
                                            addText(
                                            "Business Owner: {detail>/selectedSystem/BusinessOwner}");
                                            addText(
                                            "IT Owner: {detail>/selectedSystem/ITOwner}");
                                        });
                                    });
                                });
                            });
                        });
                        addObjectPageSection(
                        [
                            "title": "Schnittstellen-Netzwerk"
                        ], {
                            addElement("uxap:subSections", null, {
                                addObjectPageSubSection(null, {
                                    addElement("uxap:blocks", null, {
                                        addNetwork_Graph([
                                            "id": "interfaceGraph",
                                            "orientation": "LeftRight",
                                            "nodes": "{detail>/graphNodes}",
                                            "lines": "{detail>/graphLines}"
                                        ], {
                                            addNetworkNodes(null, {
                                                addNetworkNode([
                                                    "key": "{detail>key}",
                                                    "title": "{detail>title}",
                                                    "status": "{detail>status}"
                                                ]);
                                            });
                                            addNetworkLines(null, {
                                                addNetworkLine([
                                                    "from": "{detail>from}",
                                                    "to": "{detail>to}",
                                                    "title": "{detail>title}"
                                                ]);
                                            });
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

    void addObjectPageLayout(
        string[string] values = null, scope void delegate() @safe content = null) {
        addElement("uxap:ObjectPageLayout", values, content);
    }
}
