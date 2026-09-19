module uim.fiori.libraries.ui.form;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUIFormLibrary : UI5Library {
    private static SAPUIFormLibrary _instance;
    private static string prefix = "form";

    this() {
        super("SAP UIForm Library", "sap.ui.layout.form");
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

    static SAPUIFormLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUIFormLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPUIFormLibrary.prefix.length == 0 ? tag
                    : SAPUIFormLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPUIFormLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("ColumnContainerData"));
    mixin(createElement("ColumnElementData"));
    mixin(createElement("ColumnLayout"));
    mixin(createElement("Form"));
    mixin(createElement("FormContainer"));
    mixin(createElement("FormElement"));
    mixin(createElement("FormLayout"));
    mixin(createElement("ResponsiveGridLayout"));
    mixin(createElement("SemanticFormElement"));
    mixin(createElement("SimpleForm"));
}
