module uim.fiori.libraries.sapui5.ushell.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPUShellLibrary : SAPUI5Library {
    private static SAPUShellLibrary _instance;

    this() {
        super("SAP UShell Library", "sap.ushell");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for the UShell in SAP Fiori apps.";

        // Implement the initialization logic here
        return true;
    }

    static SAPUShellLibrary instance() {
        if (_instance is null) {
            _instance = new SAPUShellLibrary();
        }
        return _instance;
    }
}
