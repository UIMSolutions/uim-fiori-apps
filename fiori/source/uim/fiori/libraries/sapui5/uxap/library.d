module uim.fiori.libraries.sapui5.uxap.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUxapLibrary : SAPUI5Library {
    private static SAPUxapLibrary _instance;
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

    static SAPUxapLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUxapLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPUxapLibrary.prefix.length == 0 ? tag
                    : SAPUxapLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPUxapLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("AnchorBar"));
    mixin(createElement("BlockBase"));
    mixin(createElement("BreadCrumbs"));
    mixin(createElement("HierarchicalSelect"));
    mixin(createElement("ModelMapping"));
    mixin(createElement("ObjectPageAccessibleLandmarkInfo"));
    mixin(createElement("ObjectPageDynamicHeaderContent"));
    mixin(createElement("ObjectPageDynamicHeaderTitle"));
    mixin(createElement("ObjectPageHeader"));
    mixin(createElement("ObjectPageHeaderActionButton"));
    mixin(createElement("ObjectPageHeaderContent"));
    mixin(createElement("ObjectPageHeaderLayoutData"));
    mixin(createElement("ObjectPageLayout"));
    mixin(createElement("ObjectPageLazyLoader"));
    mixin(createElement("ObjectPageSection"));
    mixin(createElement("ObjectPageSectionBase"));
    mixin(createElement("ObjectPageSubSection"));
}
