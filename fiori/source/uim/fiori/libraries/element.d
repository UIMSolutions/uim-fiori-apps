module uim.fiori.libraries.element;

import uim.fiori;

mixin(ShowModule!());

@safe:
class UI5Element {
    this() {

    }

    this(string tag, string[string] attributes = null, UI5Element[] children = null) {
        this._tag = tag;
        this._attributes = attributes;
        this._children = children;
    }

    this(string tag, UI5Element[] children) {
        this._tag = tag;
        this._children = children;
    }

    protected string _tag;
    string tag() {
        return _tag;
    }

    protected string[string] _attributes;
    string[string] attributes() {
        return _attributes;
    }

    protected UI5Element[] _children;
    UI5Element[] children() {
        return _children;
    }
    UI5Element add(UI5Element child) {
        if (this._children is null) {
            this._children = [child];
        } else {
            this._children ~= child;
        }
        return this;
    }

    string render() {
        string result = "<" ~ this._tag;
        if (this._attributes != null) {
            foreach (string attr; this._attributes) {
                result ~= " " ~ attr;
            }
        }
        result ~= ">";
        if (this._children != null) {
            foreach (UI5Element child; this._children) {
                result ~= child.render();
            }
        }
        result ~= "</" ~ this._tag ~ ">";
        return result;
    }
}
unittest {
    void testRender() {
        UI5Element child = new UI5Element("child");
        UI5Element parent = new UI5Element("parent", null, [child]);
        assert(parent.render() == "<parent><child></child></parent>");
    }

    void testRenderWithAttributes() {
        UI5Element child = new UI5Element("child");
        UI5Element parent = new UI5Element("parent", ["class": "\"parent-class\""], [child]);
        assert(parent.render() == "<parent class=\"parent-class\"><child></child></parent>");
    }

    void testRenderWithoutChildren() {
        UI5Element parent = new UI5Element("parent", ["class": "\"parent-class\""]);
        assert(parent.render() == "<parent class=\"parent-class\"></parent>");
    }

    void testAll() {
        testRender();
        testRenderWithAttributes();
        testRenderWithoutChildren();
    }
}