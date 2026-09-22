module uim.fiori.libraries.sapui5.tnt.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPTNTLibrary : SAPUI5Library {
    private static SAPTNTLibrary _instance;
    private static string prefix = "tnt";

    this() {
        super("SAP TNT Library", "sap.tnt");
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

    static SAPTNTLibrary instance() {
        if (_instance is null) {
            _instance = new SAPTNTLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPTNTLibrary.prefix.length == 0 ? tag
                    : SAPTNTLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPTNTLibrary.Element(tag, null, content);
        }
    }
}
