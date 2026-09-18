module uim.fiori.libraries.library;

import uim.fiori;

@safe:

class UI5Library {
    string name;
    static string prefix;
    string namespace;
    string version_;

    static string getPrefix() {
        return instance().prefix;
    }

    protected string _description;
    string description() {
        return _description;
    }

    void description(string desc) {
        _description = desc;
    }
    
    string author;
    string license;
    string homepage;

    this() {
        initialize();
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        this();
        this.name = name;
        this.namespace = namespace;
        this.version_ = version_;
        this._description = description;
        this.author = author;
        this.license = license;
        this.homepage = homepage;
    }

    bool initialize(Json initData = Json.emptyObject) {
        // Implement the initialization logic here
        return true;
    }

    // Singleton-Zugriff
    protected static UI5Library _instance;
    static UI5Library instance() {
        if (_instance is null) {
            _instance = new UI5Library();
        }
        return _instance;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(UI5Library.prefix.length == 0 ? tag : UI5Library.prefix ~ ":" ~ tag, values, content);
        }
    }

    // struct Element {
    //     string tag;
    //     string[string] attributes;
    //     UI5Element[] children;

    //     UI5Element add(UI5Element child) {
    //         this.children ~= child;
    //         return this;
    //     }
    // }
    // UI5Element Element(string tag, string[string] attributes = null, UI5Element[] children = null) {
    //     return new UI5Element(prefix.length == 0 ? tag : prefix ~ ":" ~ tag, attributes, children);
    // }

    // UI5Element Element(string tag, UI5Element[] children) {
    //     return new UI5Element(prefix.length == 0 ? tag : prefix ~ ":" ~ tag, null, children);
    // }



    static UI5Library opCall() {
        return instance();
    }
}
///
unittest {    // // 1. Instantiating custom library
    // UI5Library lib = new UI5Library("TestLib", "test.namespace");
    // lib.prefix = "abc";
    // assert(lib.name == "TestLib");
    // assert(lib.namespace == "test.namespace");
    // assert(lib.prefix == "abc");    

    // // 2. Calling Element on the instance (lib), not the class (UI5Library)
    // // 3. UI5Library() via static opCall safely returns the initialized singleton
    // auto element = lib.Element("MyElement", ["id": "testElement"], [lib.Element("Span")]);
    
    // assert(element.tag == "abc:MyElement");
    // assert(element.attributes["id"] == "testElement");
    // assert(element.children.length == 1);
    // assert(element.children[0].tag == "abc:Span");

    UI5Library lib = new UI5Library("TestLib", "test.namespace");
    UI5Library.prefix = "abc";

    assert(lib.name == "TestLib");
    assert(lib.namespace == "test.namespace");
    assert(UI5Library.prefix == "abc");
    assert(lib.version_ == "");
    assert(lib._description == "");
    assert(lib.author == "");
    assert(lib.license == "");
    assert(lib.homepage == "");


    auto element = lib.Element("MyElement", ["id": "testElement"], [lib.Element("Span")]);
    writeln(element.tag);
    assert(element.tag == "abc:MyElement");
    assert(element.attributes["id"] == "testElement");
    assert(element.children.length == 1);
    assert(element.children[0].tag == "abc:Span");
}
