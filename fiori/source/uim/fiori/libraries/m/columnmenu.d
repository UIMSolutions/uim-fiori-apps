module uim.fiori.libraries.m.columnmenu;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPMColumnMenuLibrary : UI5Library {
    private static SAPMColumnMenuLibrary _instance;
    private static string prefix = "ColumnMenu";

    this() {
        super("SAP MColumnMenu Library", "sap.m.table.columnmenu");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _description = "SAPUI5 library with controls specialized for administrative applications.";

        // Implement the initialization logic here
        return true;
    }

    static SAPMColumnMenuLibrary instance() {
        if (_instance is null) {
            _instance = new SAPMColumnMenuLibrary();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPMColumnMenuLibrary.prefix.length == 0 ? tag
                    : SAPMColumnMenuLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return SAPMColumnMenuLibrary.Element(tag, null, content);
        }
    }

    mixin(createElement("ActionItem"));
    mixin(createElement("Entry"));
    mixin(createElement("ItemBase"));
    mixin(createElement("Menu"));
    mixin(createElement("MenuBase"));
    mixin(createElement("QuickAction"));
    mixin(createElement("QuickActionBase"));
    mixin(createElement("QuickActionItem"));
    mixin(createElement("QuickGroup"));
    mixin(createElement("QuickGroupItem"));
    mixin(createElement("QuickResize"));
    mixin(createElement("QuickSort"));
    mixin(createElement("QuickSortItem"));
    mixin(createElement("QuickTotal"));
    mixin(createElement("QuickTotalItem"));
}
