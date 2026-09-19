module uim.fiori.libraries.core.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPCoreLibrary : UI5Library {
    private static SAPCoreLibrary _instance;
    static string prefix = "core";

    this() {
        super("SAP Core Library", "sap.core");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 core library providing essential controls and functionalities for SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPCoreLibrary instance() {
        if (_instance is null) {
            _instance = new SAPCoreLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPCoreLibrary.prefix.length == 0 ? tag
                    : SAPCoreLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPCoreLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("CommandExecution"));
    mixin(createElement("Component"));
    mixin(createElement("ComponentContainer"));
    mixin(createElement("ComponentMetadata"));
    mixin(createElement("Control"));
    mixin(createElement("Core"));
    mixin(createElement("CustomData"));
    // mixin(createElement("CoreElement"));
    struct CoreElement {
        static UI5Element opCall(string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPCoreLibrary.prefix.length == 0 ? "Element"
                    : SAPCoreLibrary.prefix ~ ":" ~ "Element", values, content);
        }

        static UI5Element opCall(UI5Element[] content) {
            return SAPCoreLibrary.CoreElement(null, content);
        }
    }
    
    mixin(createElement("ElementMetadata"));
    mixin(createElement("EnabledPropagator"));
    mixin(createElement("EventBus"));
    mixin(createElement("Fragment"));
    mixin(createElement("History"));
    mixin(createElement("HTML"));
    mixin(createElement("Icon"));
    mixin(createElement("IntervalTrigger"));
    mixin(createElement("InvisibleMessage"));
    mixin(createElement("InvisibleText"));
    mixin(createElement("Item"));
    mixin(createElement("LayoutData"));
    mixin(createElement("Lib"));
    mixin(createElement("ListItem"));
    mixin(createElement("Locale"));
    mixin(createElement("LocaleData"));
    mixin(createElement("Manifest"));
    mixin(createElement("Popup"));
    mixin(createElement("RenderManager"));
    mixin(createElement("ResizeHandler"));
    mixin(createElement("SeparatorItem"));
    mixin(createElement("Title"));
    mixin(createElement("TooltipBase"));
    mixin(createElement("UIComponent"));
    mixin(createElement("VariantLayoutData"));

}
