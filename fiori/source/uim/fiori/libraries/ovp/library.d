module uim.fiori.libraries.ovp.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPOVPLibrary : UI5Library {
    private static SAPOVPLibrary _instance;

    this() {
        super("SAP OVP Library", "sap.ovp");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for OVP in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPOVPLibrary instance() {
        if (_instance is null) {
            _instance = new SAPOVPLibrary();
        }
        return _instance;
    }
}
