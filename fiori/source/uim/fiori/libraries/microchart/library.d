module uim.fiori.libraries.microchart.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPMicrochartLibrary : UI5Library {
    private static SAPMicrochartLibrary _instance;
    static string prefix = "micro";

    this() {
        super("SAP Microchart Library", "sap.suite.ui.microchart");
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

    static SAPMicrochartLibrary instance() {
        if (_instance is null) {
            _instance = new SAPMicrochartLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPMicrochartLibrary.prefix.length == 0 ? tag
                    : SAPMicrochartLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPMicrochartLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("AreaMicroChart"));
    mixin(createElement("AreaMicroChartItem"));
    mixin(createElement("AreaMicroChartLabel"));
    mixin(createElement("AreaMicroChartPoint"));
    mixin(createElement("BulletMicroChart"));
    mixin(createElement("BulletMicroChartData"));
    mixin(createElement("ColumnMicroChart"));
    mixin(createElement("ColumnMicroChartData"));
    mixin(createElement("ColumnMicroChartLabel"));
    mixin(createElement("ComparisonMicroChart"));
    mixin(createElement("ComparisonMicroChartData"));
    mixin(createElement("DeltaMicroChart"));
    mixin(createElement("HarveyBallMicroChart"));
    mixin(createElement("HarveyBallMicroChartItem"));
    mixin(createElement("InteractiveBarChart"));
    mixin(createElement("InteractiveBarChartBar"));
    mixin(createElement("InteractiveDonutChart"));
    mixin(createElement("InteractiveDonutChartSegment"));
    mixin(createElement("InteractiveLineChart"));
    mixin(createElement("InteractiveLineChartPoint"));
    mixin(createElement("LineMicroChart"));
    mixin(createElement("LineMicroChartEmphasizedPoint"));
    mixin(createElement("LineMicroChartLine"));
    mixin(createElement("LineMicroChartPoint"));
    mixin(createElement("RadialMicroChart"));
    mixin(createElement("StackedBarMicroChart"));
    mixin(createElement("StackedBarMicroChartBar"));
}
