module uim.fiori.libraries.ui.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUILibrary : UI5Library {
    private static SAPUILibrary _instance;

    this() {
        super("SAP UI Library", "sap.ui");
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

    static SAPUILibrary instance() {
        if (_instance is null) {
            _instance = new SAPUILibrary();
        }
        return _instance;
    }
}
