module uim.fiori.libraries.graph.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPGraphLibrary : UI5Library {
    private static SAPGraphLibrary _instance;
    static string prefix = "graph";

    this() {
        super("SAP Graph Library", "sap.suite.ui.commons.networkgraph.Graph");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for Graph in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPGraphLibrary instance() {
        if (_instance is null) {
            _instance = new SAPGraphLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPGraphLibrary.prefix.length == 0 ? tag
                    : SAPGraphLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPGraphLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("ActionButton"));
    mixin(createElement("Coordinate"));
    mixin(createElement("ElementAttribute"));
    mixin(createElement("ElementBase"));
    mixin(createElement("Graph"));
    mixin(createElement("GraphMap"));
    mixin(createElement("Group"));
    mixin(createElement("Line"));
    mixin(createElement("Node"));
    mixin(createElement("NodeImage"));
    mixin(createElement("Status"));
    mixin(createElement("SvgBase"));
}
