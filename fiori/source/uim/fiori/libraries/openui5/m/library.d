module uim.fiori.libraries.openui5.m.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class OpenUi5MLibrary : OpenUI5Library {
    private static OpenUi5MLibrary _instance;
    static string prefix = "f";

    this() {
        super("SAP M Library", "sap.m");
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

    static OpenUi5MLibrary instance() {
        if (_instance is null) {
            _instance = new OpenUi5MLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(OpenUi5MLibrary.prefix.length == 0 ? tag
                    : OpenUi5MLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return OpenUi5MLibrary.Element(tag, null, content);
        }
    }

}
