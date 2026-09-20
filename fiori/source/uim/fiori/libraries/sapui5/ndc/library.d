module uim.fiori.libraries.ndc.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPNDCLibrary : UI5Library {
    private static SAPNDCLibrary _instance;
    static string prefix = "ndc";

    this() {
        super("SAP NDC Library", "sap.ndc");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for NDC in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPNDCLibrary instance() {
        if (_instance is null) {
            _instance = new SAPNDCLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPNDCLibrary.prefix.length == 0 ? tag
                    : SAPNDCLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPNDCLibrary.Element(tag, null, content);
        }
    }
}
