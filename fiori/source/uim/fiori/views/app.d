module uim.fiori.views.app;

import uim.fiori;
import uim.xml;

@safe:
class XAppView : MvcView {
    protected string _appId;
    protected string[string] _libs;

    this() {
        super();
    }

    this(Json initData) {
        super(initData);
    }

    this(string customPath, Json initData = Json.emptyObject) {
        super(initData.set("path", customPath));
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;

        _controllerName = initData.getString("controllerName", "my.app.controller.App");
        _appId = initData.getString("appId", "app");
        _path = initData.getString("path", "/view/App.view.xml");
        if (initData.hasKey("libs") && initData["libs"].isObject) {
            initData["libs"].byKeyValue.each!((key, value) =>
                    _libs[key] = value.getString());
        } else
            _libs = [
                "xmlns:mvc": "sap.ui.core.mvc",
                "xmlns:core": "sap.ui.core",
                "xmlns": "sap.m"
            ];

        return true;
    }

    override protected void buildView() {
        // // super.buildView();
        // auto attributes = _libs.dup;
        // attributes["controllerName"] = _controllerName;
        // attributes["height"] = "100%";
        // _writer.addElement("mvc:View")
        //     .addAttributes(attributes);
        // _writer.endElement();

    }

    // override void addApp() {
    //     writer.addElement("SplitApp")
    //         .addAttribute("id", _appId)
    //     .endElement();
    // }
}
///
unittest {
    // auto appView = new XAppView();
    // assert(appView.initialize());

    // auto renderedView = appView.render;
    // assert(renderedView.canFind(`controllerName="my.app.controller.App"`));

    // appView = new XAppView("/A/B");
    // assert(appView.initialize());

    // renderedView = appView.render;
    // assert(renderedView.canFind(`controllerName="my.app.controller.App"`));

}