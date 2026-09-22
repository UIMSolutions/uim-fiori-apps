module uim.fiori.libraries.sapui5.m.table;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPMTableLibrary : SAPUI5Library {
    private static SAPMTableLibrary _instance;
    private static string prefix = "mtable";

    this() {
        super("SAP MTable Library", "sap.m.table");
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

    static SAPMTableLibrary instance() {
        if (_instance is null) {
            _instance = new SAPMTableLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPMTableLibrary.prefix.length == 0 ? tag
                    : SAPMTableLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPMTableLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("ColumnWidthController"));
    mixin(createElement("Title"));
}
