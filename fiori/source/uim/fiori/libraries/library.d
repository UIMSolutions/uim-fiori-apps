module uim.fiori.libraries.library;

import uim.fiori;

@safe:

class UI5Library {
    string name;
    string namespace;
    string version_;

    string description;
    string author;
    string license;
    string homepage;

    this() {
    }

    this(string name, string namespace, string version_ ="", string description = "", string author = "", string license = "", string homepage = "") {
        this.name = name;
        this.namespace = namespace;
        this.version_ = version_;
        this.description = description;
        this.author = author;
        this.license = license;
        this.homepage = homepage;
    }
    
    UI5Element Element(string tag, string[string] attributes = null, UI5Element[] children = null) {
        return new UI5Element(name.length == 0 ? tag : name~":"~tag, attributes, children);
    }

    UI5Element Element(string tag, UI5Element[] children) {
        return new UI5Element(name.length == 0 ? tag : name~":"~tag, null, children);
    }
}
///
unittest {
    UI5Library lib = new UI5Library("TestLib", "test.namespace");
    assert(lib.name == "TestLib");
    assert(lib.namespace == "test.namespace");
}