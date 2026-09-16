module uim.fiori.views.mvc;

import uim.fiori;
import uim.xml;

@safe:
class MvcView : FioriView {
    protected string[string] _libs;
    protected string _controllerName;
    protected string _height = "100%";

    this() {
        super();
    }

    this(Json initData) {
        super(initData);
    }

    this(string customPath, Json initData = Json(null)) {
        super(initData.set("path", customPath));
    }

    override bool initialize(Json initData = Json(null)) {
        if (!super.initialize(initData))
            return false;

        _path = initData.getString("path", "/view/App.view.xml");
        _controllerName = initData.getString("controllerName", "my.app.controller.App");
        _height = initData.getString("height", "100%");
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
        // super.buildView();
        auto attributes = _libs.dup;
        attributes["controllerName"] = _controllerName;
        attributes["height"] = _height;
        _writer.addElement("mvc:View")
            .addAttributes(attributes);
        addApp();
        _writer.endElement();

    }

    override void addApp(string[string] values = null, scope void delegate() @safe content = null) {
        super.addApp(values, { 
        });
    }
}
///
unittest {
    auto mvcView = new MvcView();
    assert(mvcView.initialize());

    auto renderedView = mvcView.render;

    mvcView = new MvcView("/view/App.view.xml");
    assert(mvcView.initialize());

    renderedView = mvcView.render;
}