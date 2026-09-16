module uim.fiori.projectmanager.presentation.ui5.views.app;

import uim.fiori.projectmanager;
import uim.xml;

@safe:
class AppView : UI5View {
    this(string viewPath) {
        super(viewPath);
    }
    
    override string render() {
        _writer.addElement("mvc:View")
            .addAttributes(["controllerName": "projects.app.controller.App",
                            "xmlns:mvc": "sap.ui.core.mvc",
                            "xmlns": "sap.m",
                            "displayBlock": "true"])
            .addElement("SplitApp")
                .addAttribute("id", "app")
            .endElement()
            .endElement();
            
        return _writer.toString();
    }
}
