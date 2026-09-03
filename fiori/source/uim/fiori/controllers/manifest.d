module uim.fiori.controllers.manifest;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.regex : regex, replaceFirst;
import std.string : indexOf, strip;

@safe:

private size_t findMatchingPair(string text, size_t startPos, char openChar,
        char closeChar) {
    size_t depth = 0;
    for (size_t idx = startPos; idx < text.length; ++idx) {
        if (text[idx] == openChar) {
            ++depth;
        } else if (text[idx] == closeChar) {
            if (depth == 0) {
                return size_t.max;
            }
            --depth;
            if (depth == 0) {
                return idx;
            }
        }
    }

    return size_t.max;
}

private string insertIntoArray(string content, string key, string value) {
    auto keyPos = indexOf(content, "\"" ~ key ~ "\"");
    if (keyPos < 0) {
        return content;
    }

    auto arrayStart = indexOf(content, '[', cast(size_t) keyPos);
    if (arrayStart < 0) {
        return content;
    }

    auto arrayEnd = findMatchingPair(content, cast(size_t) arrayStart, '[', ']');
    if (arrayEnd == size_t.max) {
        return content;
    }

    string before = content[0 .. cast(size_t) arrayStart + 1];
    string middle = content[cast(size_t) arrayStart + 1 .. arrayEnd];
    string after = content[arrayEnd .. $];

    auto trimmed = middle.strip();
    auto buf = appender!string();

    if (trimmed.length == 0) {
        buf.put("\n          ");
        buf.put(value);
        buf.put("\n        ");
    } else {
        buf.put(middle);
        buf.put(",\n          ");
        buf.put(value);
        buf.put("\n        ");
    }

    return before ~ buf.data ~ after;
}

private string insertIntoObject(string content, string key, string keyValuePair) {
    auto keyPos = indexOf(content, "\"" ~ key ~ "\"");
    if (keyPos < 0) {
        return content;
    }

    auto objectStart = indexOf(content, '{', cast(size_t) keyPos);
    if (objectStart < 0) {
        return content;
    }

    auto objectEnd = findMatchingPair(content, cast(size_t) objectStart, '{', '}');
    if (objectEnd == size_t.max) {
        return content;
    }

    string before = content[0 .. cast(size_t) objectStart + 1];
    string middle = content[cast(size_t) objectStart + 1 .. objectEnd];
    string after = content[objectEnd .. $];

    auto trimmed = middle.strip();
    auto buf = appender!string();

    if (trimmed.length == 0) {
        buf.put("\n          ");
        buf.put(keyValuePair);
        buf.put("\n        ");
    } else {
        buf.put(middle);
        buf.put(",\n          ");
        buf.put(keyValuePair);
        buf.put("\n        ");
    }

    return before ~ buf.data ~ after;
}

string upsertResourceRoot(string manifestJson, string namespaceName,
        string localPath = "./") {
    string propertyA = "\"" ~ namespaceName ~ "\": \"" ~ localPath ~ "\"";
    if (manifestJson.canFind(propertyA)) {
        return manifestJson;
    }

    if (!manifestJson.canFind("\"resourceRoots\"")) {
        return replaceFirst(
            manifestJson,
            regex(`"sap\.ui5"\s*:\s*\{`),
            "\"sap.ui5\": {\n      \"resourceRoots\": {\n        " ~ propertyA ~ "\n      },"
        );
    }

    return insertIntoObject(manifestJson, "resourceRoots", propertyA);
}

string upsertRouteAndTarget(
        string manifestJson,
        string routeName,
        string routePattern,
        string targetName,
        string viewPath,
        string viewName,
        string controlId = "app",
        string controlAggregation = "pages") {
    auto updated = manifestJson;

    if (!updated.canFind("\"name\": \"" ~ routeName ~ "\"")
            && !updated.canFind("\"name\":\"" ~ routeName ~ "\"")) {
        string routeItem = "{ \"name\": \"" ~ routeName ~ "\", \"pattern\": \""
            ~ routePattern ~ "\", \"target\": \"" ~ targetName ~ "\" }";
        updated = insertIntoArray(updated, "routes", routeItem);
    }

    if (!updated.canFind("\"" ~ targetName ~ "\":")
            && !updated.canFind("\"" ~ targetName ~ "\" :")) {
        string targetItem = "\"" ~ targetName ~ "\": { "
            ~ "\"viewType\": \"XML\", "
            ~ "\"viewPath\": \"" ~ viewPath ~ "\", "
            ~ "\"viewName\": \"" ~ viewName ~ "\", "
            ~ "\"controlId\": \"" ~ controlId ~ "\", "
            ~ "\"controlAggregation\": \"" ~ controlAggregation ~ "\" }";
        updated = insertIntoObject(updated, "targets", targetItem);
    }

    return updated;
}

string registerControllerAndRouting(
        string manifestJson,
        string appNamespace,
        string routeName,
        string routePattern,
        string targetName,
        string viewName) {
    auto withNamespace = upsertResourceRoot(manifestJson, appNamespace, "./");
    return upsertRouteAndTarget(
        withNamespace,
        routeName,
        routePattern,
        targetName,
        appNamespace ~ ".view",
        viewName
    );
}

unittest {
    string manifest = q{
{
  "sap.ui5": {
    "routing": {
      "routes": [],
      "targets": {}
    }
  }
}
};

    auto updated = registerControllerAndRouting(
        manifest,
        "demo.app",
        "main",
        "",
        "main",
        "Main"
    );

    assert(updated.canFind("\"resourceRoots\""));
    assert(updated.canFind("\"name\": \"main\""));
    assert(updated.canFind("\"main\": {"));
    assert(updated.canFind("\"viewPath\": \"demo.app.view\""));
}
