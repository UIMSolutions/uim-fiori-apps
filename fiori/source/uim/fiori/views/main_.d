module uim.fiori.views.main_;

import uim.fiori;
import uim.xml;

@safe:
class MainView : MvcView {
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

        _controllerName = "my.app.controller.Main";
        return true;
    }

    // override protected void buildView() {
    //     // super.buildView();
    //     auto attributes = _libs.dup;
    //     attributes["controllerName"] = _controllerName;
    //     attributes["height"] = _height;
    //     _writer.addElement("mvc:View")
    //         .addAttributes(attributes);
    //     _writer.endElement();

    // }
}
///
unittest {
    // auto mainView = new MainView();
    // assert(mainView.initialize());

    // auto renderedView =  mainView.render;
    // assert(renderedView.canFind(`controllerName="my.app.controller.Main"`));

    // auto mainView2 = new MainView("/view/App.view.xml");
    // assert(mainView2.initialize());

    // renderedView = mainView2.render;
}