module uim.fiori.libraries.openui5.base.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class OpenUi5BaseLibrary : OpenUI5Library {
    private static OpenUi5BaseLibrary _instance;
    static string prefix = "f";

    this() {
        super("SAP Base Library", "sap.base");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static OpenUi5BaseLibrary instance() {
        if (_instance is null) {
            _instance = new OpenUi5BaseLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(OpenUi5BaseLibrary.prefix.length == 0 ? tag
                    : OpenUi5BaseLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return OpenUi5BaseLibrary.Element(tag, null, content);
        }
    }

}
