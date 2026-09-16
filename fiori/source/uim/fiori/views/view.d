module uim.fiori.views.view;

import uim.fiori;
import uim.xml;

@safe:
class FioriView {
    protected string _path;
    protected auto _writer = new OOPXMLWriter!string();
    protected string _content;

    this() {
        initialize();
    }

    this(Json initData) {
        initialize(initData);
    }

    this(string customPath, Json initData = Json(null)) {
        _path = customPath;
        initialize(initData);
    }

    bool initialize(Json initData = Json(null)) {
        return true;
    }

    void registerRoutes(URLRouter router) {
        router.get(_path, &handler);
    }

    void handler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        if (_content.length == 0) {
            _content = render();
        }
        // writeln(_content);
        res.writeBody(_content, "application/xml");
    }

    string render() {
        _writer = new OOPXMLWriter!string();
        buildView();
        return _writer.toString();
    }

    protected void buildView() {
    }

    void addElement(string name, string[string] values = null, scope void delegate() @safe content = null) {
        _writer.addElement(name)
            .addAttributes(values);
        if (content !is null) {
            content();
        }
        _writer.endElement();
    }

    void addElement(string name, scope void delegate() @safe content) {
        addElement(name, null, content);
    }

    void addText(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Text", values, content);
    }

    void addText(string text) {
        addText(["text": text]);
    }

    void addLabel(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Label", values, content);
    }

    void addLabel(string text) {
        addLabel(["text": text]);
    }

    void addButton(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Button", values, content);
    }

    void addInput(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Input", values, content);
    }

    void addVBox(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("VBox", values, content);
    }

    void addVBox(scope void delegate() @safe content) {
        addElement("VBox", null, content);
    }

    void addHBox(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("HBox", values, content);
    }

    void addHBox(scope void delegate() @safe content) {
        addElement("HBox", null, content);
    }

    void addApp(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("App", values, content);
    }

    void addPage(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Page", values, content);
    }

    void addTable(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Table", values, content);
    }

    void addSimpleForm(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("layout:SimpleForm", values, content);
    }

    void addColumnListItem(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ColumnListItem", values, content);
    }

    void addToolbar(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Toolbar", values, content);
    }

    void addTitle(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Title", values, content);
    }

    void addTitle(string text) {
        addTitle(["text": text]);
    }

    void addColumn(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Column", values, content);
    }

    void addColumns(string[string][] columns) {
        addElement("columns", null, {
            foreach (column; columns) {
                string text = column["text"];
                column.remove("text");
                addColumn(column, { addText([
                        "text": text
                    ]); });
            }
        });
    }

    void addColumns(string[] columns) {
        addColumns(columns.map!(column => ["text": column]).array);
    }

    void addSelect(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Select", values, content);
    }

    void addDatePicker(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("DatePicker", values, content);
    }

    void addHeaderToolbar(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("HeaderToolbar", values, content);
    }

    void addLayoutContent(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("LayoutContent", values, content);
    }

    void addObjectNumber(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ObjectNumber", values, content);
    }

    void addToolbarSpacer(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ToolbarSpacer", values, content);
    }

    void addObjectStatus(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ObjectStatus", values, content);
    }

    void addCoreItem(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("core:Item", values, content);
    }

    void addIconTabBar(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("IconTabBar", values, content);
    }

    void addCells(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("cells", values, content);
    }

    void addObjectIdentifier(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ObjectIdentifier", values, content);
    }

    void addNetworkLines(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("network:lines", values, content);
    }

    void addNetwork_Graph(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("network:Graph", values, content);
    }

    void addNetworkGraph(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("graph:NetworkGraph", values, content);
    }

    void addNetworkLine(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("network:Line", values, content);
    }

    void addNetworkNodes(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("network:nodes", values, content);
    }

    void addNetworkNode(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("network:Node", values, content);
    }

    void addObjectPageSection(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("uxap:ObjectPageSection", values, content);
    }

    void addObjectPageSubSection(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("uxap:ObjectPageSubSection", values, content);
    }

    void addObjectPageSubSections(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("uxap:subSections", values, content);
    }

    void addPanel(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("Panel", values, content);
    }

    void addIconTabFilter(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("IconTabFilter", values, content);
    }

    void addBulletMicroChart(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("micro:BulletMicroChart", values, content);
    }

    void addProportionalTimeStrategy(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("ax:ProportionalTimeStrategy", values, content);
    }

    void addGanttChartWithTable(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("gantt:GanttChartWithTable", values, content);
    }

    void addRadialMicroChart(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("micro:RadialMicroChart", values, content);
    }

    void addBulletMicroChartData(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("micro:BulletMicroChartData", values, content);
    }

    void addProcessFlow(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("pf:ProcessFlow", values, content);
    }

    void addProcessFlowNode(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("pf:ProcessFlowNode", values, content);
    }

    void addProcessFlowLaneHeader(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("pf:ProcessFlowLaneHeader", values, content);
    }

    void addProcessFlowNodes(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("pf:nodes", values, content);
    }

    void addProcessFlowLanes(string[string] values = null, scope void delegate() @safe content = null) {
        addElement("pf:lanes", values, content);
    }


}
