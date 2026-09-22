module uim.fiori.libraries.sapui5.vk.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPVkLibrary : SAPUI5Library {
    private static SAPVkLibrary _instance;
    private static string prefix = "vk";

    this() {
        super("SAP Vk Library", "sap.vk");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for the Vk library in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPVkLibrary instance() {
        if (_instance is null) {
            _instance = new SAPVkLibrary();
        }
        return _instance;
    }

        struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPVkLibrary.prefix.length == 0 ? tag
                    : SAPVkLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPVkLibrary.Element(tag, null, content);
        }
    }
}
