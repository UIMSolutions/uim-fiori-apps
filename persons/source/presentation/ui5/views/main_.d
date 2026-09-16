module presentation.ui5.views.main_;
import uim.fiori;
@safe:
class MainView : FioriView {
    this(string path) {
        super(path);
    }
    string renderView() {
        writer.addElement("mvc:View")
            .addAttributes(["controllerName": "personapp.Main",
                            "xmlns:mvc": "sap.ui.core.mvc",
                            "xmlns": "sap.m",
                            "xmlns:f": "sap.ui.layout.form",
                            "height": "100%"])
            .addElement("App")
                .addElement("pages")
                    .addPage()
                .endElement() // pages
            .endElement() // App
        .endElement(); // mvc:View
        return writer.toString();
    }

    void addPage() {
        writeln("Creating page");
        writer.addElement("Page")
            .addAttribute("title", "Personenverwaltung (vibe.d + SAP Fiori)")
            .addElement("content")
                .addPanel()
                .addTable()
            .endElement() // content
        .endElement(); // Page
    }

    void addPanel() {
        writeln("Creating panel");
        writer.addElement("Panel")
            .addAttribute("headerText", "Neue Person anlegen")
            .addAttribute("expandable", "true")
            .addAttribute("expanded", "true")
            .addElement("f:SimpleForm")
                .addAttribute("editable", "true")
                .addAttribute("layout", "ColumnLayout")
                .addElement("Label")
                    .addAttribute("text", "Name")
                .endElement()
                .addElement("Input")
                    .addAttribute("value", "{newPerson>/name}")
                .endElement()
                .addElement("Label")
                    .addAttribute("text", "E-Mail")
                .endElement()
                .addElement("Input")
                    .addAttribute("value", "{newPerson>/email}")
                .endElement()
                .addElement("Label")
                    .addAttribute("text", "Rolle")
                .endElement()
                .addElement("Input")
                    .addAttribute("value", "{newPerson>/role}")
                .endElement()
                .addElement("Button")
                    .addAttribute("text", "Speichern")
                    .addAttribute("type", "Emphasized")
                    .addAttribute("press", "onAddPerson")
                .endElement()
            .endElement() // f:SimpleForm
        .endElement(); // Panel
    }

    void addTable() {
        writeln("Creating table");
        writer.addElement("Table")
            .addAttribute("items", "{persons>/}")
            .addElement("columns")
                .addElement("Column").addElement("Text").addAttribute("text", "ID").endElement().endElement()
                .addElement("Column").addElement("Text").addAttribute("text", "Name").endElement().endElement()
                .addElement("Column").addElement("Text").addAttribute("text", "E-Mail").endElement().endElement()
                .addElement("Column").addElement("Text").addAttribute("text", "Rolle").endElement().endElement()
                .addElement("Column").addAttribute("hAlign", "End").addElement("Text").addAttribute("text", "Aktion").endElement().endElement()
            .endElement() // columns
            .addElement("items")
                .addElement("ColumnListItem")
                    .addElement("cells")
                        .addElement("Text").addAttribute("text", "{persons>id}").endElement()
                        .addElement("ObjectIdentifier").addAttribute("title", "{persons>name}").endElement()
                        .addElement("Text").addAttribute("text", "{persons>email}").endElement()
                        .addElement("Text").addAttribute("text", "{persons>role}").endElement()
                        .addElement("Button").addAttribute("icon", "sap-icon://delete").addAttribute("type", "Reject").addAttribute("press", "onDeletePerson").endElement()
                    .endElement() // cells
                .endElement() // ColumnListItem
            .endElement() // items
        .endElement(); // Table
    }
}