module uim.fiori.views.app;

import uim.fiori;
import uim.xml;

@safe:
class AppView : FioriView {
    protected string _path = "/view/App.view.xml";
    protected auto writer = new OOPXMLWriter!string();
    protected string _content;
    this() {
    }

    this(string customPath) {
        _path = customPath;
    }

    void registerRoutes(URLRouter router) {
        router.get(_path, &handler);
    }
}