module uim.fiori.libraries.gantt.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPGanttLibrary : UI5Library {
    private static SAPGanttLibrary _instance;

    this() {
        super("SAP Gantt Library", "sap.gantt");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for Gantt charts in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPGanttLibrary instance() {
        if (_instance is null) {
            _instance = new SAPGanttLibrary();
        }
        return _instance;
    }
}
