module uim.fiori.libraries.ui.grid;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUIGridLibrary : UI5Library {
    private static SAPUIGridLibrary _instance;
    private static string prefix = "grid";

    this() {
        super("SAP UIGrid Library", "sap.grid");
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

    static SAPUIGridLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUIGridLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPUIGridLibrary.prefix.length == 0 ? tag
                    : SAPUIGridLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPUIGridLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("CSSGrid"));
    mixin(createElement("GridBasicLayout"));
    mixin(createElement("GridBoxLayout"));
    mixin(createElement("GridItemLayoutData"));
    mixin(createElement("GridLayoutBase"));
    mixin(createElement("GridLayoutDelegate"));
    mixin(createElement("GridResponsiveLayout"));
    mixin(createElement("GridSettings"));
    mixin(createElement("ResponsiveColumnItemLayoutData"));
    mixin(createElement("ResponsiveColumnLayout"));
}
