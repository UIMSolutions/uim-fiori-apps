module uim.fiori.controllers.controller;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.file : exists, mkdirRecurse, readText, write;
import std.path : buildPath, dirName;
import std.regex : matchAll, regex, replaceFirst;
import std.string : join, split;
import uim.fiori.controllers.manifest;
import uim.fiori.views;

@safe:

struct ControllerMethod {
    string name;
    string[] bodyLines;
    string[] parameters;
}

struct ControllerConfig {
    string namespace;
    string name;
    string[] dependencies;
    ControllerMethod[] methods;
    bool withBaseController = true;
}

private void ensureParentFolder(string filePath) {
    auto parent = dirName(filePath);
    if (parent.length > 0 && parent != ".") {
        mkdirRecurse(parent);
    }
}

private string jsQuote(string value) {
    auto buf = appender!string();
    foreach (ch; value) {
        switch (ch) {
            case '\\': buf.put("\\\\"); break;
            case '"': buf.put("\\\""); break;
            case '\n': buf.put("\\n"); break;
            case '\r': buf.put("\\r"); break;
            case '\t': buf.put("\\t"); break;
            default: buf.put(ch); break;
        }
    }
    return buf.data;
}

string buildController(ControllerConfig cfg) {
    string[] deps = cfg.dependencies.dup;
    if (cfg.withBaseController) {
        bool hasBase = false;
        foreach (dep; deps) {
            if (dep == "sap/ui/core/mvc/Controller") {
                hasBase = true;
                break;
            }
        }
        if (!hasBase) {
            deps = ["sap/ui/core/mvc/Controller"] ~ deps;
        }
    }

    string[] aliases;
    foreach (dep; deps) {
        auto parts = dep.split("/");
        aliases ~= parts[$ - 1];
    }

    auto buf = appender!string();
    buf.put("sap.ui.define([\n");

    foreach (idx, dep; deps) {
        buf.put("    \"");
        buf.put(jsQuote(dep));
        buf.put("\"");
        if (idx + 1 < deps.length) {
            buf.put(",");
        }
        buf.put("\n");
    }

    buf.put("], function (");
    buf.put(aliases.join(", "));
    buf.put(") {\n");
    buf.put("    \"use strict\";\n\n");

    string baseAlias = cfg.withBaseController ? aliases[0] : "Controller";
    buf.put("    return ");
    buf.put(baseAlias);
    buf.put(".extend(\"");
    buf.put(jsQuote(cfg.namespace ~ "." ~ cfg.name));
    buf.put("\", {\n");

    foreach (idx, method; cfg.methods) {
        buf.put("        ");
        buf.put(method.name);
        buf.put(": function (");
        buf.put(method.parameters.join(", "));
        buf.put(") {\n");

        if (method.bodyLines.length == 0) {
            buf.put("            // TODO: Implement\n");
        } else {
            foreach (line; method.bodyLines) {
                buf.put("            ");
                buf.put(line);
                buf.put("\n");
            }
        }

        buf.put("        }");
        if (idx + 1 < cfg.methods.length) {
            buf.put(",");
        }
        buf.put("\n");
    }

    buf.put("    });\n");
    buf.put("});\n");

    return buf.data;
}

ControllerConfig listReportController(string namespace, string name) {
    return ControllerConfig(
        namespace,
        name,
        ["sap/m/MessageToast"],
        [
            ControllerMethod("onInit", ["// View model wiring goes here"], []),
            ControllerMethod("onRefresh", [
                "var oBinding = this.byId(\"list\").getBinding(\"items\");",
                "if (oBinding) {",
                "    oBinding.refresh();",
                "}",
                "MessageToast.show(\"List refreshed\");"
            ], []),
            ControllerMethod("onItemPress", [
                "var oItem = oEvent.getParameter(\"listItem\");",
                "if (oItem) {",
                "    MessageToast.show(\"Pressed: \" + oItem.getTitle());",
                "}"
            ], ["oEvent"])
        ]
    );
}

ControllerConfig objectPageController(string namespace, string name) {
    return ControllerConfig(
        namespace,
        name,
        ["sap/m/MessageToast"],
        [
            ControllerMethod("onInit", [
                "// Load object page context"
            ], []),
            ControllerMethod("onEdit", [
                "MessageToast.show(\"Edit mode\");"
            ], []),
            ControllerMethod("onSave", [
                "MessageToast.show(\"Changes saved\");"
            ], []),
            ControllerMethod("onNavBack", [
                "history.go(-1);"
            ], [])
        ]
    );
}

ControllerConfig createEditController(string namespace, string name) {
    return ControllerConfig(
        namespace,
        name,
        ["sap/m/MessageToast"],
        [
            ControllerMethod("onInit", [
                "// Prepare create/edit form model"
            ], []),
            ControllerMethod("onCreate", [
                "MessageToast.show(\"Record created\");"
            ], []),
            ControllerMethod("onUpdate", [
                "MessageToast.show(\"Record updated\");"
            ], []),
            ControllerMethod("onCancel", [
                "history.go(-1);"
            ], [])
        ]
    );
}

void writeControllerFile(ControllerConfig config, string filePath) {
    ensureParentFolder(filePath);
    write(filePath, buildController(config));
}

string readControllerFile(string filePath) {
    return readText(filePath);
}

string[] extractHandlerNames(string jsControllerContent) {
    string[] methods;
    foreach (capture; matchAll(jsControllerContent,
            regex(`\b([A-Za-z_][A-Za-z0-9_]*)\s*:\s*function\s*\(`))) {
        methods ~= capture.captures[1];
    }
    return methods;
}

string upsertMethod(string jsControllerContent, ControllerMethod method) {
    auto existing = extractHandlerNames(jsControllerContent);
    foreach (name; existing) {
        if (name == method.name) {
            string replacement = method.name ~ ": function (" ~ method.parameters.join(", ") ~ ") {\n";
            if (method.bodyLines.length == 0) {
                replacement ~= "            // TODO: Implement\n";
            } else {
                foreach (line; method.bodyLines) {
                    replacement ~= "            " ~ line ~ "\n";
                }
            }
            replacement ~= "        }";

            return replaceFirst(jsControllerContent,
                regex(`\b` ~ method.name ~ `\s*:\s*function\s*\([^\)]*\)\s*\{[\s\S]*?\n\s*\}`),
                replacement
            );
        }
    }

    string insertBlock = "\n        " ~ method.name ~ ": function (" ~ method.parameters.join(", ") ~ ") {\n";
    if (method.bodyLines.length == 0) {
        insertBlock ~= "            // TODO: Implement\n";
    } else {
        foreach (line; method.bodyLines) {
            insertBlock ~= "            " ~ line ~ "\n";
        }
    }
    insertBlock ~= "        }";

    if (jsControllerContent.canFind("    });")) {
        return replaceFirst(jsControllerContent, regex(`\n\s*\}\);\s*$`), "," ~ insertBlock ~ "\n    });\n");
    }

    return jsControllerContent;
}

void scaffoldListReportApp(
        string appNamespace,
        string viewName,
        string controllerName,
        string webappRoot,
        string routeName = "main",
        string routePattern = "") {
    auto viewFilePath = buildPath(webappRoot, "view", viewName ~ ".view.xml");
    auto controllerFilePath = buildPath(
        webappRoot,
        "controller",
        controllerName ~ ".controller.js"
    );

    auto viewNode = xmlView(
        appNamespace ~ ".controller." ~ controllerName,
        app("app", [
            page("Contacts", [
                title("Contacts"),
                input("search", bindPath("filters>/query"), "Search contacts"),
                list("list", bindPath("/contacts"), [
                    standardListItem(bindPath("name"), bindPath("email"))
                ])
            ], "mainPage")
        ])
    );

    ensureParentFolder(viewFilePath);
    writeXmlView(viewNode, viewFilePath);

    auto controllerCfg = listReportController(appNamespace ~ ".controller", controllerName);
    writeControllerFile(controllerCfg, controllerFilePath);

    auto manifestPath = buildPath(webappRoot, "manifest.json");
    if (exists(manifestPath)) {
        auto content = readText(manifestPath);
        auto updated = registerControllerAndRouting(
            content,
            appNamespace,
            routeName,
            routePattern,
            routeName,
            viewName
        );
        write(manifestPath, updated);
    }
}

unittest {
    auto cfg = listReportController("demo.controller", "Main");
    auto js = buildController(cfg);

    assert(js.canFind("sap.ui.define"));
    assert(js.canFind("demo.controller.Main"));
    assert(js.canFind("onRefresh: function ()"));
    assert(extractHandlerNames(js).length >= 3);

    auto updated = upsertMethod(js,
        ControllerMethod("onSearch", [
            "var sQuery = oEvent.getParameter(\"query\") || \"\";",
            "console.log(sQuery);"
        ], ["oEvent"])
    );

    assert(updated.canFind("onSearch: function (oEvent)"));

    auto objectPage = buildController(objectPageController("demo.controller", "Object"));
    assert(objectPage.canFind("onSave: function ()"));

    auto createEdit = buildController(createEditController("demo.controller", "Editor"));
    assert(createEdit.canFind("onCreate: function ()"));
}
