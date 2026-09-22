module uim.fiori.libraries.sapui5.viz.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPVizLibrary : SAPUI5Library {
    private static SAPVizLibrary _instance;
    private static string prefix = "viz";

    this() {
        super("SAP Viz Library", "sap.viz");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for the Viz library in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPVizLibrary instance() {
        if (_instance is null) {
            _instance = new SAPVizLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPVizLibrary.prefix.length == 0 ? tag
                    : SAPVizLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPVizLibrary.Element(tag, null, content);
        }
    }


}
