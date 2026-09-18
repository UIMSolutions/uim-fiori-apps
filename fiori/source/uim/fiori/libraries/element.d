module uim.fiori.libraries.element;

import uim.fiori;

mixin(ShowModule!());

@safe:
struct UI5Element {
    string tag;
    string[string] attributes;
    UI5Element[] children;

    UI5Element add(UI5Element child) {
        this.children ~= child;
        return this;
    }

    string render() {
        string result = "<" ~ tag;
        foreach (key, value; attributes) {
            result ~= " " ~ key ~ "=\"" ~ value ~ "\"";
        }
        result ~= ">";
        foreach (child; children) {
            result ~= child.render();
        }
        result ~= "</" ~ tag ~ ">";
        return result;
    }

    Json toJson() const {
        Json jAttributes = Json.emptyObject;
        foreach(key, value; attributes) {
            jAttributes[key] = value;
        }

        return Json.emptyObject
            .set("tag", tag)
            .set("attributes", jAttributes)
            .set("children", children.map!(child => child.toJson()).array.toJson);
    }
}
///
unittest {
    UI5Element element;
    element.tag = "div";
    element.attributes = ["id": "testDiv"];
    element.children = [UI5Element("span", ["id": "testSpan"], null)];

    assert(element.tag == "div");
    assert(element.attributes["id"] == "testDiv");
    assert(element.children.length == 1);
    assert(element.children[0].tag == "span");
    assert(element.children[0].attributes["id"] == "testSpan");

    element.add(UI5Element("p", ["id": "testP"], null));
    assert(element.children.length == 2);
    assert(element.children[1].tag == "p");
    assert(element.children[1].attributes["id"] == "testP");
}

string createElement(string tag) {
    return 
    `struct ` ~ tag ~ ` {
        static UI5Element opCall(string[string] values = null, UI5Element[] content = null) {
            return Element("` ~ tag ~ `", values, content);
        }

        static UI5Element opCall(UI5Element[] content) {
            return ` ~ tag ~ `(null, content);
        }
    }`;
}

string createElementWithText(string tag) {
    return 
    `struct ` ~ tag ~ ` {
        static UI5Element opCall(string[string] values = null, UI5Element[] content = null) {
            return Element("` ~ tag ~ `", values, content);
        }

        static UI5Element opCall(UI5Element[] content) {
            return ` ~ tag ~ `(null, content);
        }

        static UI5Element opCall(string text) {
            return ` ~ tag ~ `(["text": text]);
        }
    }`;
}