module uim.fiori.projectmanager.presentation.ui5.views.master;
import uim.fiori.projectmanager;
import uim.xml;
@safe:
class MasterView : UI5View {
    this(string viewPath) {
        super(viewPath);
    }
    
    override string render() {
        writeln("Creating view");
        _writer.addElement("mvc:View")
            .addAttributes(["controllerName": "projects.app.controller.Master",
                            "xmlns:mvc": "sap.ui.core.mvc",
                            "xmlns": "sap.m"]);
        addPage(["title": "Projekte"], {
            addPageSubHeader();
            addList();
        });
        _writer.endElement();
        return _writer.toString();
    }

    void addPageSubHeader() {
        writeln("Creating sub header");
        addElement("subHeader", {
            addToolbar();
        });
    }

    void addToolbar() {
        writeln("Creating toolbar");
        addElement("Toolbar", {
            addButton();
        });
    }
    
    void addButton() {
        writeln("Creating button");
        addElement("Button", [
            "text": "Neues Projekt",
            "press": "onOpenAddProjectDialog",
            "icon": "sap-icon://add"
        ]);
    }

    void addList() {
        writeln("Creating list");
        addElement("List", [
            "id": "projectList",
            "items": "{/Projects}"
        ], {
            addElement("items", {
                addElement("StandardListItem", [
                    "title": "{Name}",
                    "description": "{Description}",
                    "type": "Navigation",
                    "press": "onItemPress"
                ]);
            });
        });
    }
}
        