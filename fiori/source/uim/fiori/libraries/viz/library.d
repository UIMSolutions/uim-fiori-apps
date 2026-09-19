module uim.fiori.libraries.vk.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPVkLibrary : UI5Library {
    private static SAPVkLibrary _instance;
    private static string prefix = "vk";

    this() {
        super("SAP Vk Library", "sap.ui.vk");
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

    mixin(createElement("AnimationPlayer"));
    mixin(createElement("Annotation"));
    mixin(createElement("BaseNodeProxy"));
    mixin(createElement("Camera"));
    mixin(createElement("ContentConnector"));
    mixin(createElement("ContentManager"));
    mixin(createElement("ContentResource"));
    mixin(createElement("DrawerToolbar"));
    mixin(createElement("FlexibleControl"));
    mixin(createElement("FlexibleControlLayoutData"));
    mixin(createElement("ImageContentManager"));
    mixin(createElement("LayerProxy"));
    mixin(createElement("Loco"));
    mixin(createElement("Material"));
    mixin(createElement("NativeViewport"));
    mixin(createElement("NodeHierarchy"));
    mixin(createElement("NodeProxy"));
    mixin(createElement("Notifications"));
    mixin(createElement("OrthographicCamera"));
    mixin(createElement("OutputSettings"));
    mixin(createElement("PerspectiveCamera"));
    mixin(createElement("RedlineCollaboration"));
    mixin(createElement("RedlineConversation"));
    mixin(createElement("RedlineDesign"));
    mixin(createElement("RedlineElement"));
    mixin(createElement("RedlineElementComment"));
    mixin(createElement("RedlineElementEllipse"));
    mixin(createElement("RedlineElementFreehand"));
    mixin(createElement("RedlineElementLine"));
    mixin(createElement("RedlineElementRectangle"));
    mixin(createElement("RedlineElementText"));
    mixin(createElement("RedlineSurface"));
    mixin(createElement("SafeArea"));
    mixin(createElement("Scene"));
    mixin(createElement("SceneTree"));
    mixin(createElement("Texture"));
    mixin(createElement("ToggleMenuButton"));
    mixin(createElement("Toolbar"));
    mixin(createElement("View"));
    mixin(createElement("Viewer"));
    mixin(createElement("ViewGallery"));
    mixin(createElement("ViewGroup"));
    mixin(createElement("ViewManager"));
    mixin(createElement("Viewport"));
    mixin(createElement("ViewportBase"));
    mixin(createElement("ViewStateManager"));
    mixin(createElement("ViewStateManagerBase"));
}
