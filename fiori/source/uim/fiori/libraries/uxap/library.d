module uim.fiori.libraries.uxap.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUXAPLibrary : UI5Library {
    private static SAPUXAPLibrary _instance;
    static string prefix = "uxap";

    this() {
        super("SAP UXAP Library", "sap.uxap");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for the UXAP in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPUXAPLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUXAPLibrary();
        }
        return _instance;
    }

        struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPUXAPLibrary.prefix.length == 0 ? tag
                    : SAPUXAPLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPUXAPLibrary.Element(tag, null, content);
        }
    }
}
