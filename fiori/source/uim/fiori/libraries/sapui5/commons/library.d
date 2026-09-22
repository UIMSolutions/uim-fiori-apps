module uim.fiori.libraries.sapui5.commons.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPCommonsLibrary : SAPUI5Library {
    private static SAPCommonsLibrary _instance;
    private static string prefix = "commons";

    this() {
        super("SAP Commons Library", "sap.suite.ui.commons");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for NDC in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPCommonsLibrary instance() {
        if (_instance is null) {
            _instance = new SAPCommonsLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPCommonsLibrary.prefix.length == 0 ? tag
                    : SAPCommonsLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPCommonsLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("AriaProperties"));
    mixin(createElement("CalculationBuilder"));
    mixin(createElement("CalculationBuilderFunction"));
    mixin(createElement("CalculationBuilderGroup"));
    mixin(createElement("CalculationBuilderItem"));
    mixin(createElement("CalculationBuilderValidationResult"));
    mixin(createElement("CalculationBuilderVariable"));
    mixin(createElement("ChartContainer"));
    mixin(createElement("ChartContainerContent"));
    mixin(createElement("ChartContainerToolbarPlaceholder"));
    mixin(createElement("CloudFilePicker"));
    mixin(createElement("MicroProcessFlow"));
    mixin(createElement("MicroProcessFlowItem"));
    mixin(createElement("ProcessFlow"));
    mixin(createElement("ProcessFlowConnection"));
    mixin(createElement("ProcessFlowConnectionLabel"));
    mixin(createElement("ProcessFlowLaneHeader"));
    mixin(createElement("ProcessFlowNode"));
    mixin(createElement("Timeline"));
    mixin(createElement("TimelineFilterListItem"));
    mixin(createElement("TimelineItem"));
    mixin(createElement("TimelineNavigator"));
    
}
