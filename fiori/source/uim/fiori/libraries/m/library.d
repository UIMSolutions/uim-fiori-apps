module uim.fiori.libraries.m.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPMLibrary : UI5Library {
    private static SAPMLibrary _instance;

    this() {
        super("", "sap.m");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    // Singleton-Zugriff
    static SAPMLibrary instance() {
        if (_instance is null) {
            _instance = new SAPMLibrary();
        }
        return _instance;
    }

    static UI5Element Text(string[string] attributes = null, UI5Element[] children = null) {
        // Verwende die Singleton-Instanz statt SAPMLibrary()
        return instance.Element("Text", attributes, children);
    }

    static UI5Element Text(UI5Element[] children) {
        return Text(null, children);
    }
}

auto Library() {
    return SAPMLibrary.instance();
}
///
unittest {
    SAPMLibrary lib = new SAPMLibrary();
    assert(lib.name == "");
    assert(lib.namespace == "sap.m");

    UI5Element text = SAPMLibrary.Text(["id": "testText"], [new UI5Element("Span")]);
    writeln(text.render);
    assert(text.tag == "Text");
    assert(text.attributes["id"] == "testText");
    assert(text.children.length == 1);
    assert(text.children[0].tag == "Span");
}