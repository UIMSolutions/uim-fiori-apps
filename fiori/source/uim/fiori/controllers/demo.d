module uim.fiori.controllers.demo;

import std.algorithm.searching : canFind;
import std.file : exists, mkdirRecurse, readText, remove, rmdirRecurse, write;
import std.path : buildPath;
import std.random : uniform;
import std.string : format;

import uim.fiori.controllers.controller;
import uim.fiori.controllers.manifest;

@safe:

void runListReportScaffoldDemo(string webappRoot) {
    mkdirRecurse(buildPath(webappRoot, "view"));
    mkdirRecurse(buildPath(webappRoot, "controller"));

    auto manifestPath = buildPath(webappRoot, "manifest.json");
    if (!exists(manifestPath)) {
        write(manifestPath, q{
{
  "sap.ui5": {
    "routing": {
      "routes": [],
      "targets": {}
    }
  }
}
});
    }

    scaffoldListReportApp(
        "demo.app",
        "Main",
        "Main",
        webappRoot,
        "main",
        ""
    );
}

  void runObjectAndEditScaffoldDemo(string webappRoot) {
    mkdirRecurse(buildPath(webappRoot, "controller"));

    auto objectControllerPath = buildPath(webappRoot, "controller", "Object.controller.js");
    auto editorControllerPath = buildPath(webappRoot, "controller", "Editor.controller.js");

    writeControllerFile(
      objectPageController("demo.app.controller", "Object"),
      objectControllerPath
    );

    writeControllerFile(
      createEditController("demo.app.controller", "Editor"),
      editorControllerPath
    );

    auto manifestPath = buildPath(webappRoot, "manifest.json");
    if (!exists(manifestPath)) {
      write(manifestPath, q{
  {
    "sap.ui5": {
    "routing": {
      "routes": [],
      "targets": {}
    }
    }
  }
  });
    }

    auto manifest = readText(manifestPath);
    manifest = registerControllerAndRouting(
      manifest,
      "demo.app",
      "object",
      "object/{id}",
      "object",
      "Object"
    );

    manifest = registerControllerAndRouting(
      manifest,
      "demo.app",
      "editor",
      "editor/{id}",
      "editor",
      "Editor"
    );

    write(manifestPath, manifest);
  }

unittest {
    auto suffix = format("%08x", uniform(0u, uint.max));
    auto root = buildPath("/tmp", "uim-fiori-demo-" ~ suffix);

    mkdirRecurse(root);
    scope (exit) {
        if (exists(root)) {
            rmdirRecurse(root);
        }
    }

    runListReportScaffoldDemo(root);

    auto viewPath = buildPath(root, "view", "Main.view.xml");
    auto controllerPath = buildPath(root, "controller", "Main.controller.js");
    auto manifestPath = buildPath(root, "manifest.json");

    assert(exists(viewPath));
    assert(exists(controllerPath));
    assert(exists(manifestPath));

    auto view = readText(viewPath);
    auto controller = readText(controllerPath);
    auto manifest = readText(manifestPath);

    assert(view.canFind("mvc:View"));
    assert(controller.canFind("sap.ui.define"));
    assert(manifest.canFind("\"resourceRoots\""));
}

  unittest {
    auto suffix = format("%08x", uniform(0u, uint.max));
    auto root = buildPath("/tmp", "uim-fiori-demo-object-editor-" ~ suffix);

    mkdirRecurse(root);
    scope (exit) {
      if (exists(root)) {
        rmdirRecurse(root);
      }
    }

    runObjectAndEditScaffoldDemo(root);

    auto objectControllerPath = buildPath(root, "controller", "Object.controller.js");
    auto editorControllerPath = buildPath(root, "controller", "Editor.controller.js");
    auto manifestPath = buildPath(root, "manifest.json");

    assert(exists(objectControllerPath));
    assert(exists(editorControllerPath));
    assert(exists(manifestPath));

    auto objectController = readText(objectControllerPath);
    auto editorController = readText(editorControllerPath);
    auto manifest = readText(manifestPath);

    assert(objectController.canFind("onSave: function ()"));
    assert(editorController.canFind("onCreate: function ()"));
    assert(manifest.canFind("\"name\": \"object\""));
    assert(manifest.canFind("\"name\": \"editor\""));
  }
