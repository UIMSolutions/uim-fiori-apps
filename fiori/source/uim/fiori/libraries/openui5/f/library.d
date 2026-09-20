module uim.fiori.libraries.openui5.f.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class OpenUi5FLibrary : UI5Library {
    private static OpenUi5FLibrary _instance;
    static string prefix = "f";

    this() {
        super("SAP F Library", "sap.f");
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

    static OpenUi5FLibrary instance() {
        if (_instance is null) {
            _instance = new OpenUi5FLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(OpenUi5FLibrary.prefix.length == 0 ? tag
                    : OpenUi5FLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return OpenUi5FLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("AvatarGroup"));
    mixin(createElement("AvatarGroupItem"));
    mixin(createElement("Card"));
    mixin(createElement("CardBase"));
    mixin(createElement("DynamicPage"));
    mixin(createElement("DynamicPageAccessibleLandmarkInfo"));
    mixin(createElement("DynamicPageHeader"));
    mixin(createElement("DynamicPageTitle"));
    mixin(createElement("FlexibleColumnLayout"));
    mixin(createElement("FlexibleColumnLayoutAccessibleLandmarkInfo"));
    mixin(createElement("FlexibleColumnLayoutData"));
    mixin(createElement("FlexibleColumnLayoutDataForDesktop"));
    mixin(createElement("FlexibleColumnLayoutDataForTablet"));
    mixin(createElement("FlexibleColumnLayoutSemanticHelper"));
    mixin(createElement("GridContainer"));
    mixin(createElement("GridContainerItemLayoutData"));
    mixin(createElement("GridContainerSettings"));
    mixin(createElement("GridList"));
    mixin(createElement("GridListItem"));
    mixin(createElement("ProductSwitch"));
    mixin(createElement("ProductSwitchItem"));
    mixin(createElement("SearchManager"));
    mixin(createElement("ShellBar"));
    mixin(createElement("SidePanel"));
    mixin(createElement("SidePanelItem"));

}
