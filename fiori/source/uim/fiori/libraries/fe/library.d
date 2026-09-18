module uim.fiori.libraries.fe.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPFELibrary : UI5Library {
    private static SAPFELibrary _instance;

    this() {
        super("SAP Fiori Elements Library", "sap.fe");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "Root namespace for all the libraries related to SAP Fiori elements.";

        // Implement the initialization logic here
        return true;
    }

    static SAPFELibrary instance() {
        if (_instance is null) {
            _instance = new SAPFELibrary();
        }
        return _instance;
    }
}
