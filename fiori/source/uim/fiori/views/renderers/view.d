module uim.fiori.views.renderers.view;

import uim.fiori;

@safe:

class ViewRenderer {
    this() {
    }

    protected string[string] _libs;
    string[string] libs() {
        return _libs;
    }

    auto libs(string[string] newLibs) {
        _libs = newLibs;
        return this;
    }

    auto addLib(string name, string lib) {
        _libs[name] = lib;
        return this;
    }

    auto updateLib(string name, string lib) {
        _libs[name] = lib;
        return this;
    }

    auto removeLib(string name) {
        _libs.remove(name);
        return this;
    }

    protected string _controllerName;
    string controllerName() {
        return _controllerName;
    }

    auto controllerName(string newControllerName) {
        _controllerName = newControllerName;
        return this;
    }

    protected string _height = "100%";
    string height() {
        return _height;
    }

    auto height(string newHeight) {
        _height = newHeight;
        return this;
    }

    protected UI5Element[] _elements;
    UI5Element[] elements() {
        return _elements;
    }

    auto elements(UI5Element[] newElements) {
        _elements = newElements;
        return this;
    }

    auto addElement(UI5Element element) {
        _elements ~= element;
        return this;
    }

    string render() {
        return "";
    }
    
    string renderElement(UI5Element element ) {
        return "";
    }
}
///
unittest {
    auto renderer = new ViewRenderer();
    assert(renderer.libs().length == 0);
    assert(renderer.controllerName() == "");
    assert(renderer.height() == "100%");

    renderer.libs(["a":"lib1", "b":"lib2"]);
    assert(renderer.libs().length == 2);

    renderer.controllerName("NewController");
    assert(renderer.controllerName() == "NewController");

    renderer.height("200px");
    assert(renderer.height() == "200px");

    renderer.addElement(new UI5Element("elementName"));
    assert(renderer.elements().length == 1);
}
