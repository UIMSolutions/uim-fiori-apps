module uim.fiori.views.xml;

import std.algorithm.searching : canFind;
import std.array : Appender, appender;
import std.file : readText, write;
import std.regex : matchAll;

@safe:

class XmlElement {
private:
    struct XmlAttribute {
        string name;
        string value;
    }

    string _name;
    string _text;
    XmlAttribute[] _attributes;
    XmlElement[] _children;

public:
    this(string name) {
        _name = name;
    }

    @property string name() const {
        return _name;
    }

    XmlElement attr(string name, string value) {
        foreach (ref item; _attributes) {
            if (item.name == name) {
                item.value = value;
                return this;
            }
        }

        _attributes ~= XmlAttribute(name, value);
        return this;
    }

    XmlElement text(string value) {
        _text = value;
        return this;
    }

    XmlElement add(XmlElement child) {
        _children ~= child;
        return this;
    }

    XmlElement addIf(bool condition, XmlElement child) {
        if (condition) {
            _children ~= child;
        }
        return this;
    }

    XmlElement withChildren(XmlElement[] children) {
        _children ~= children;
        return this;
    }

    XmlElement[] children() {
        return _children.dup;
    }

    string render(bool pretty = true, size_t indentSize = 2) const {
        auto buf = appender!string();
        renderInto(buf, 0, pretty, indentSize);
        return buf.data;
    }

private:
    static string makeIndent(size_t level, size_t indentSize) {
        auto buf = appender!string();
        foreach (_; 0 .. level * indentSize) {
            buf.put(' ');
        }
        return buf.data;
    }

    static string escapeXml(string value) {
        auto buf = appender!string();
        foreach (ch; value) {
            switch (ch) {
                case '&': buf.put("&amp;"); break;
                case '<': buf.put("&lt;"); break;
                case '>': buf.put("&gt;"); break;
                case '"': buf.put("&quot;"); break;
                case '\'': buf.put("&apos;"); break;
                default: buf.put(ch); break;
            }
        }
        return buf.data;
    }

    void renderInto(ref Appender!string buf, size_t level, bool pretty,
            size_t indentSize) const {
        string indent;
        if (pretty) {
            indent = makeIndent(level, indentSize);
            buf.put(indent);
        }

        buf.put("<");
        buf.put(_name);

        foreach (attr; _attributes) {
            buf.put(" ");
            buf.put(attr.name);
            buf.put("=\"");
            buf.put(escapeXml(attr.value));
            buf.put("\"");
        }

        bool hasChildren = _children.length > 0;
        bool hasText = _text.length > 0;

        if (!hasChildren && !hasText) {
            buf.put("/>");
            if (pretty) {
                buf.put("\n");
            }
            return;
        }

        buf.put(">");

        if (hasText) {
            buf.put(escapeXml(_text));
        }

        if (hasChildren) {
            if (pretty) {
                buf.put("\n");
            }
            foreach (child; _children) {
                child.renderInto(buf, level + 1, pretty, indentSize);
            }
            if (pretty) {
                buf.put(indent);
            }
        }

        buf.put("</");
        buf.put(_name);
        buf.put(">");
        if (pretty) {
            buf.put("\n");
        }
    }
}

XmlElement el(string name) {
    return new XmlElement(name);
}

void writeXmlView(XmlElement root, string filePath, bool pretty = true,
        size_t indentSize = 2) {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" ~ root.render(pretty,
            indentSize);
    write(filePath, xml);
}

string readXmlView(string filePath) {
    return readText(filePath);
}

string[] extractControlIds(string xmlContent) {
    string[] ids;
    foreach (capture; matchAll(xmlContent, `id="([^"]+)"`)) {
        ids ~= capture.captures[1];
    }
    return ids;
}

string withControllerName(string xmlContent, string controllerName) {
    import std.regex : regex, replaceFirst;

    return replaceFirst(xmlContent,
            regex(`controllerName\s*=\s*"[^"]*"`),
            "controllerName=\"" ~ controllerName ~ "\"");
}

unittest {
    auto node = el("Label").attr("id", "nameLabel").attr("text", "Name");
    auto xml = node.render();
    assert(xml.canFind("<Label"));
    assert(xml.canFind("id=\"nameLabel\""));
}
