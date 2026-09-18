module uim.fiori.views.view;

import uim.fiori;
import uim.xml;

@safe:
class UI5View {
    protected string _path;
    // protected UI5Element rootElement;
    protected bool _isStatic;
    protected string _cache;
    protected ViewRenderer _renderer;

    this() {
        initialize();
    }

    this(Json initData) {
        initialize(initData);
    }

    this(string customPath, Json initData = Json.emptyObject) {
        initialize(initData.set("path", customPath));
    }

    bool initialize(Json initData = Json.emptyObject) {
        _renderer = new XMLViewRenderer();
        if (initData.getString("renderer") == "XML")
            _renderer = new XMLViewRenderer();

        _path = initData.getString("path", "/view/UI5.view.xml");

        return true;
    }

    ViewRenderer renderer() {
        return _renderer;
    }

    auto renderer(ViewRenderer newRenderer) {
        _renderer = newRenderer;
        return this;
    }

    void handler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        if (_isStatic && _cache.length == 0) {
            _cache = render();
        }

        auto resBody = _isStatic ? _cache : render();
        res.writeBody(resBody, "application/xml");
    }

    void registerRoutes(URLRouter router) {
        router.get(_path, &handler);
    }

    string escapeXML(string input) {
        import uim.xml;

        return escapeXML(input);
    }

    protected string renderAttributes(string[string] attributes) {    
        return attributes.byKeyValue.map!(kv => kv.key ~ "=\"" ~ escapeXML(kv.value) ~ "\"").array.join(" ");
    }

    protected UI5Element[] buildView() {
        return null;
    }

    protected string renderElement(UI5Element element) {    
        return "<" ~ element.tag ~ " " ~ renderAttributes(element.attributes) ~ ">" ~ renderElements(element.children) ~ "</" ~ element.tag ~ ">";
    }

    protected string renderElements(UI5Element[] elements) {
        auto rendered = appender!string;
        foreach (element; elements) {
            rendered.put(renderElement(element));
        }
        return rendered.data;
    }

    string render() {
        return renderer.render(buildView());
    }


//     void addElement(string name, string[string] values = null, scope void delegate() @safe content = null) {
//         UI5Element element = new UI5Element(name, valuesToAttributes(values));
//         if (content !is null) {
//             content();
//         }
//         _elements ~= element;
//     }

//     void addElement(string name, scope void delegate() @safe content) {
//         addElement(name, null, content);
//     }

//     void addText(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Text", values, content);
//     }

//     void addText(string text) {
//         addText(["text": text]);
//     }

//     void addLabel(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Label", values, content);
//     }

//     void addLabel(string text) {
//         addLabel(["text": text]);
//     }

//     void addButton(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Button", values, content);
//     }

//     void addInput(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Input", values, content);
//     }

//     void addVBox(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("VBox", values, content);
//     }

//     void addVBox(scope void delegate() @safe content) {
//         addElement("VBox", null, content);
//     }

//     void addHBox(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("HBox", values, content);
//     }

//     void addHBox(scope void delegate() @safe content) {
//         addElement("HBox", null, content);
//     }

//     void addApp(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("App", values, content);
//     }

//     void addPage(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Page", values, content);
//     }

//     void addTable(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Table", values, content);
//     }

//     void addSimpleForm(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("layout:SimpleForm", values, content);
//     }

//     void addColumnListItem(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("ColumnListItem", values, content);
//     }

//     void addColumn(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Column", values, content);
//     }

//     void addColumns(string[string][] columns) {
//         addElement("columns", null, {
//             foreach (column; columns) {
//                 string text = column["text"];
//                 column.remove("text");
//                 addColumn(column, { addText([
//                         "text": text
//                     ]); });
//             }
//         });
//     }



//     void addCoreItem(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("core:Item", values, content);
//     }

//     void addIconTabBar(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("IconTabBar", values, content);
//     }

//     void addCells(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("cells", values, content);
//     }

//     void addObjectIdentifier(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("ObjectIdentifier", values, content);
//     }

//     void addNetworkLines(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("network:lines", values, content);
//     }

//     void addNetwork_Graph(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("network:Graph", values, content);
//     }

//     void addNetworkGraph(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("graph:NetworkGraph", values, content);
//     }

//     void addNetworkLine(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("network:Line", values, content);
//     }

//     void addNetworkNodes(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("network:nodes", values, content);
//     }

//     void addNetworkNode(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("network:Node", values, content);
//     }

//     void addObjectPageSection(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("uxap:ObjectPageSection", values, content);
//     }

//     void addObjectPageSubSection(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("uxap:ObjectPageSubSection", values, content);
//     }

//     void addObjectPageSubSections(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("uxap:subSections", values, content);
//     }

//     void addPanel(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("Panel", values, content);
//     }

//     void addIconTabFilter(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("IconTabFilter", values, content);
//     }

//     void addBulletMicroChart(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("micro:BulletMicroChart", values, content);
//     }

//     void addProportionalTimeStrategy(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("ax:ProportionalTimeStrategy", values, content);
//     }

//     void addGanttChartWithTable(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("gantt:GanttChartWithTable", values, content);
//     }

//     void addRadialMicroChart(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("micro:RadialMicroChart", values, content);
//     }

//     void addBulletMicroChartData(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("micro:BulletMicroChartData", values, content);
//     }

//     void addProcessFlow(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("pf:ProcessFlow", values, content);
//     }

//     void addProcessFlowNode(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("pf:ProcessFlowNode", values, content);
//     }

//     void addProcessFlowLaneHeader(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("pf:ProcessFlowLaneHeader", values, content);
//     }

//     void addProcessFlowNodes(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("pf:nodes", values, content);
//     }

//     void addProcessFlowLanes(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("pf:lanes", values, content);
//     }
}
///
unittest {
    SAPMLibrary lib = new SAPMLibrary();
    auto view = new class UI5View {
        override UI5Element[] buildView() {
            return [lib.Text("Hello World")];
        }
    };
    assert(view !is null);
    // assert(view.render() !is null);

    assert(view.render().canFind("Hello World"));

    // view.addElement("Text1");
    // view.addElement("Text2", ["text": "Hello World"]);
    // view.addElement("Text3", ["text": "Hello World"], null);
    // view.addElement("Text4", ["text": "Hello World"], {
        // view.addText("Hello World");
    // });
    // view.addElement("Text5", { view.addText("Hello World"); });
    // writeln(view.render());
}
