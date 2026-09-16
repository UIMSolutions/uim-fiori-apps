module uim.fiori.views.fiori;

import std.algorithm.searching : canFind;
import uim.fiori.views.xml;

@safe:

enum string NsMvc = "sap.ui.core.mvc";
enum string NsCore = "sap.ui.core";
enum string NsM = "sap.m";
string bindPath(string path) {
    return "{" ~ path ~ "}";
}
string bindExpr(string expression) {
    return "{=" ~ expression ~ "}";
}
XMLElement xmlView(string controllerName, XMLElement rootControl) {
    return el("mvc:View")
        .attr("controllerName", controllerName)
        .attr("displayBlock", "true")
        .attr("xmlns:mvc", NsMvc)
        .attr("xmlns:core", NsCore)
        .attr("xmlns", NsM)
        .add(rootControl);
}
XMLElement app(string id, XMLElement[] pages) {
    return el("App")
        .attr("id", id)
        .add(el("pages").withChildren(pages));
}
XMLElement page(string title, XMLElement[] content, string id = "") {
    auto pageNode = el("Page").attr("title", title);
    if (id.length > 0) {
        pageNode.attr("id", id);
    }
    pageNode.add(el("content").withChildren(content));
    return pageNode;
}
XMLElement vbox(XMLElement[] items, string id = "") {
    auto box = el("VBox");
    if (id.length > 0) {
        box.attr("id", id);
    }
    box.withChildren(items);
    return box;
}
XMLElement input(string id, string valueBinding, string placeholder = "") {
    auto control = el("Input")
        .attr("id", id)
        .attr("value", valueBinding);
    if (placeholder.length > 0) {
        control.attr("placeholder", placeholder);
    }
    return control;
}

XMLElement button(string id, string text, string pressHandler = "") {
    auto control = el("Button")
        .attr("id", id)
        .attr("text", text);
    if (pressHandler.length > 0) {
        control.attr("press", pressHandler);
    }
    return control;
}
XMLElement list(string id, string itemsBinding, XMLElement[] itemsTemplate) {
    return el("List")
        .attr("id", id)
        .attr("items", itemsBinding)
        .add(el("items").withChildren(itemsTemplate));
}
XMLElement standardListItem(string titleBinding, string descriptionBinding = "") {
    auto item = el("StandardListItem").attr("title", titleBinding);
    if (descriptionBinding.length > 0) {
        item.attr("description", descriptionBinding);
    }
    return item;
}
XMLElement title(string textValue, string level = "H2") {
    return el("Title").attr("text", textValue).attr("level", level);
}
XMLElement objectStatus(string textBinding, string stateBinding) {
    return el("ObjectStatus")
        .attr("text", textBinding)
        .attr("state", stateBinding);
}
unittest {
    auto viewNode = xmlView("demo.controller.Main",
        app("mainApp", [
            page("Contacts", [
                title("Contact List"),
                list("contactsList", bindPath("/contacts"), [
                    standardListItem(bindPath("name"), bindPath("email"))
                ])
            ], "contactsPage")
        ])
    );
    auto xml = viewNode.render();
    assert(xml.canFind("mvc:View"));
    assert(xml.canFind("controllerName=\"demo.controller.Main\""));
    assert(xml.canFind("items=\"{/contacts}\""));
}
