module uim.fiori.libraries.uxap.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUXAPLibrary : UI5Library {
    private static SAPUXAPLibrary _instance;

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

    static SAPUXAPLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUXAPLibrary();
        }
        return _instance;
    }
}
