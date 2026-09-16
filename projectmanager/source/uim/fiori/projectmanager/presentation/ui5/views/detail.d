module uim.fiori.projectmanager.presentation.ui5.views.detail;
import uim.fiori.projectmanager;
import uim.xml;

@safe:
class DetailView : FioriView {
    this(string viewPath) {
        super(viewPath);
    }

    override string render() {
        writeln("Creating view");

        _writer.addElement("mvc:View")
            .addAttributes([
                "controllerName": "projects.app.controller.Detail",
                "xmlns:mvc": "sap.ui.core.mvc",
                "xmlns": "sap.m"
            ]);
        addxPage();
        _writer.endElement();
        return _writer.toString();
    }

    void addxPage() {
        writeln("Creating page");
        addPage(["title": "{Name}"], { addPageCustomHeader(); addPageContent(); });
    }

    void addPageCustomHeader() {
        writeln("Creating custom header");
        addElement("customHeader", {
            addElement("OverflowToolbar", {
                addElement("Title", [
                    "text": "{Name}"
                ]);
                addElement("ToolbarSpacer");
                addElement("Button", [
                    "icon": "sap-icon://edit",
                    "text": "Bearbeiten",
                    "press": "onOpenEditProjectDialog"
                ]);
            });
        });
    }

    void addPageContent() {
        writeln("Creating page content");
        addElement("content", {
            addElement("ObjectHeader", [
                "title": "{Name}",
                "intro": "{Description}"
            ]);
        });
        // Additional content like Tables can be added here
        addTable();
        // _writer.endElement(); // content
    }

    void addTable() {
        writeln("Creating table");
        addElement("Table", [
            "id": "todoTable",
            "items": "{Todos}",
            "headerText": "Aufgaben (Todos)"
        // Add headerToolbar, columns, and items as needed
        addHeaderToolbar();
        addColumns();
        addItems();
        ]);
        _writer.endElement(); // Table
    }

    void addHeaderToolbar() {
        writeln("Creating header toolbar");
        _writer.addElement("headerToolbar");
        _writer.addElement("OverflowToolbar");
        _writer.addElement("Title")
            .addAttribute("text", "Aufgaben")
            .endElement();
        _writer.addElement("ToolbarSpacer").endElement();
        _writer.addElement("Button")
            .addAttribute("icon", "sap-icon://add")
            .addAttribute("text", "Neue Aufgabe")
            .addAttribute("press", "onOpenAddTodoDialog")
            .endElement();
        _writer.endElement(); // OverflowToolbar
        _writer.endElement(); // headerToolbar
    }

    void addColumns() {
        writeln("Creating columns for the table");
        _writer.addElement("columns");
        _writer.addElement("Column").addElement("Text").addAttribute("text", "ID").endElement()
            .endElement();
        _writer.addElement("Column").addElement("Text").addAttribute("text", "Aufgabe").endElement()
            .endElement();
        _writer.addElement("Column").addElement("Text").addAttribute("text", "Status").endElement()
            .endElement();
        _writer.addElement("Column").addAttribute("width", "8em").addElement("Text")
            .addAttribute("text", "Aktionen").endElement().endElement();
        _writer.endElement(); // columns
    }

    void addItems() {
        writeln("Creating items for the table");
        _writer.addElement("items");
        _writer.addElement("ColumnListItem");
        _writer.addElement("cells");
        _writer.addElement("Text").addAttribute("text", "{Id}").endElement();
        _writer.addElement("Text").addAttribute("text", "{Title}").endElement();
        _writer.addElement("ObjectStatus")
            .addAttribute("text", "{ path: 'Completed', formatter: '.formatTodoStatusText' }")
            .addAttribute("state", "{ path: 'Completed', formatter: '.formatTodoStatusState' }")
            .endElement();

        addHBox([
            "renderType": "Bare",
            "justifyContent": "Start",
            "alignItems": "Center"
        ], {
            addButton([
                "icon": "sap-icon://edit",
                "tooltip": "Aufgabe bearbeiten",
                "press": "onOpenEditTodoDialog"
            ]);
            addButton([
                "icon": "sap-icon://delete",
                "type": "Reject",
                "tooltip": "Aufgabe löschen",
                "press": "onDeleteTodo"
            ]);
        }); // HBox
        _writer.endElement(); // cells
        _writer.endElement(); // ColumnListItem
        _writer.endElement(); // items
    }
}
