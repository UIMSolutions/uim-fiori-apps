module uim.fiori.views.renderers.xml;

import uim.fiori;
import dxml.dom;
import dxml.parser;

@safe:

class XMLViewRenderer : ViewRenderer {
    this() {
        super();
    }

    protected bool shouldPrettyPrint = false;

    auto pretty(bool newPretty) {
        shouldPrettyPrint = newPretty;
        return this;
    }

    string prettyPrint(string rawXml, string indentStr = "  ") {
        // Parse into a DOM representation (lazy ranges under the hood)
        auto dom = parseDOM(rawXml);
        auto app = appender!string();

        void formatNode(DOMEntity!string node, size_t depth) {
            string currentIndent = "";
            foreach (_; 0 .. depth)
                currentIndent ~= indentStr;

            final switch (node.type) {
                // dxml splits elements into Start, End, and Empty types
            case EntityType.elementStart:
            case EntityType.elementEmpty:
                app.formattedWrite("%s<%s", currentIndent, node.name);
                foreach (attr; node.attributes) {
                    app.formattedWrite(" %s=\"%s\"", attr.name, attr.value);
                }

                if (node.children.empty) {
                    app.put("/>\n");
                } else {
                    app.put(">\n");
                    foreach (child; node.children) {
                        formatNode(child, depth + 1);
                    }
                    app.formattedWrite("%s</%s>\n", currentIndent, node.name);
                }
                break;

            case EntityType.elementEnd:
                // End tags are handled parent-side when rendering children
                break;

            case EntityType.text:
                import std.string : strip;

                string trimmed = node.text.strip();
                if (!trimmed.empty) {
                    app.formattedWrite("%s%s\n", currentIndent, trimmed);
                }
                break;

            case EntityType.comment:
                app.formattedWrite("%s<!--%s-->\n", currentIndent, node.text);
                break;

            case EntityType.cdata:
                app.formattedWrite("%s<![CDATA[%s]]>\n", currentIndent, node.text);
                break;

            case EntityType.pi:
                app.formattedWrite("%s<?%s %s?>\n", currentIndent, node.name, node.text);
                break;
            }
        }

        foreach (child; dom.children) {
            formatNode(child, 0);
        }

        return app.data;
    }

    override string renderElement(UI5Element element) {
        string result = "<" ~ element.tag;
        if (element.attributes != null) {
            foreach (string key, string value; element.attributes) {
                result ~= " " ~ key ~ "=\"" ~ value ~ "\"";
            }
        }
        result ~= ">";
        if (element.children != null) {
            foreach (UI5Element child; element.children) {
                result ~= renderElement(child);
            }
        }
        result ~= "</" ~ element.tag ~ ">";
        return result;
    }

    override string render() {
        auto result = "<mvc:View";
        if (_controllerName != "") {
            result ~= " controllerName=\"" ~ _controllerName ~ "\"";
        }
        if (libs().length > 0) {
            result ~= " " ~ libs().byKeyValue.map!(kv => kv.key ~ "=\"" ~ kv.value ~ "\"").join(
                " ");
        }
        result ~= ">";

        foreach (element; _elements) {
            result ~= renderElement(element);
        }
        result ~= "</mvc:View>";
        return (shouldPrettyPrint) ? prettyPrint(result) : result;
    }
}
///
unittest {
    auto renderer = new XMLViewRenderer();
    assert(renderer.libs().length == 0);
    assert(renderer.controllerName() == "");
    assert(renderer.height() == "100%");

    renderer.libs(["xmlns:a": "lib1", "xmlns": "lib2"]);
    assert(renderer.libs().length == 2);

    renderer.controllerName("NewController");
    assert(renderer.controllerName() == "NewController");

    renderer.height("200px");
    assert(renderer.height() == "200px");

    writeln(renderer.render());

    renderer.pretty(true);
    writeln(renderer.render());

    renderer.addElement(new UI5Element("elementName"));
    writeln(renderer.render());

    renderer.addElement((new UI5Element("elementName2")).add(new UI5Element("childOfElementName2")));
    writeln(renderer.render());

    renderer.addElement((new UI5Element("elementName3", ["class":"element-class"])).add(new UI5Element("childOfElementName3")));
    writeln(renderer.render());
}
