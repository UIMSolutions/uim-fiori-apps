module uim.fiori.libraries.sapui5.ovp.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPOVPLibrary : SAPUI5Library {
    private static SAPOVPLibrary _instance;
    private static string prefix = "ovp";

    this() {
        super("SAP OVP Library", "sap.ovp");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for OVP in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPOVPLibrary instance() {
        if (_instance is null) {
            _instance = new SAPOVPLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPOVPLibrary.prefix.length == 0 ? tag
                    : SAPOVPLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPOVPLibrary.Element(tag, null, content);
        }
    }
}
