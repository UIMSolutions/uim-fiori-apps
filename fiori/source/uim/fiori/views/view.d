module uim.fiori.views.view;

import uim.fiori;
import uim.xml;

@safe:
class UI5View {
    protected string _path;
    // protected UI5Element rootElement;
    protected bool _isStatic = false;
    protected string _cache = "";
    protected ViewRenderer _renderer;

    this() {
        initialize();
    }

    this(Json initData) {
        initialize(initData);
    }

    this(string customPath, Json initData = Json.emptyObject) {
        _renderer = new XMLViewRenderer();
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
        writeln("UI5View:Handling request for path: " ~ _path);
        writeln("UI5View:isStatic: ", _isStatic);
        if (_isStatic && _cache.length == 0) {
            _cache = render();
        }

        auto resBody = _isStatic ? _cache : render();
        writeln("UI5View:Response body: " ~ resBody);
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
        writeln("UI5View:Building view for path: " ~ _path);

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
        writeln("UI5View:Rendering view at path: " ~ _path);
        writeln("UI5View:Calling buildView for path: " ~ _path);

        auto view = buildView();
        writeln("UI5View:Built view for UI5Elements: ", view.length);
        return renderer.render(view);
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

//     void addSimpleForm(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("layout:SimpleForm", values, content);
//     }

//     void addCoreItem(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("core:Item", values, content);
//     }

//     void addCells(string[string] values = null, scope void delegate() @safe content = null) {
//         addElement("cells", values, content);
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
