module uim.fiori.libraries.ui.layout;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPLayoutLibrary : UI5Library {
    private static SAPLayoutLibrary _instance;
    private static string prefix = "layout";

    this() {
        super("SAP LAYOUT Library", "sap.layout");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for administrative applications.";

        // Implement the initialization logic here
        return true;
    }

    static SAPLayoutLibrary instance() {
        if (_instance is null) {
            _instance = new SAPLayoutLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPLayoutLibrary.prefix.length == 0 ? tag
                    : SAPLayoutLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPLayoutLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("BlockLayout"));
    mixin(createElement("BlockLayoutCell"));
    mixin(createElement("BlockLayoutCellData"));
    mixin(createElement("BlockLayoutRow"));
    mixin(createElement("DynamicSideContent"));
    mixin(createElement("FixFlex"));
    mixin(createElement("Grid"));
    mixin(createElement("GridData"));
    mixin(createElement("HorizontalLayout"));
    mixin(createElement("PaneContainer"));
    mixin(createElement("ResponsiveFlowLayout"));
    mixin(createElement("ResponsiveFlowLayoutData"));
    mixin(createElement("ResponsiveSplitter"));
    mixin(createElement("SplitPane"));
    mixin(createElement("Splitter"));
    mixin(createElement("SplitterLayoutData"));
    mixin(createElement("VerticalLayout"));
}
