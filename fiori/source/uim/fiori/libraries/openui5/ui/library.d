module uim.fiori.libraries.openui5.ui.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class OpenUi5UiLibrary : OpenUI5Library {
    private static OpenUi5UiLibrary _instance;
    static string prefix = "ui";

    this() {
        super("SAP UI Library", "sap.ui");
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

    static OpenUi5UiLibrary instance() {
        if (_instance is null) {
            _instance = new OpenUi5UiLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(OpenUi5UiLibrary.prefix.length == 0 ? tag
                    : OpenUi5UiLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return OpenUi5UiLibrary.Element(tag, null, content);
        }
    }

}
