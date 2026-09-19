module uim.fiori.libraries.m.library;

import uim.fiori;

mixin(ShowModule!());

@safe:
class SAPMLibrary : UI5Library {
    private static SAPMLibrary _instance;
    static string prefix = "m";

    this() {
        super("SAP M Library", "sap.m");
    }

    this(string name, string namespace, string version_ = "", string description = "", string author = "", string license = "", string homepage = "") {
        super(name, namespace, version_, description, author, license, homepage);
    }

    override bool initialize(Json initData = Json.emptyObject) {
        if (!super.initialize(initData))
            return false;
        _description = "SAPUI5 library with controls specialized for mobile applications in SAP Fiori apps.";
        // Implement the initialization logic here
        return true;
    }

    struct Element {
        static UI5Element opCall(string tag, string[string] values = null, UI5Element[] content = null) {
            return UI5Element(SAPMLibrary.prefix.length == 0 ? tag : SAPMLibrary.prefix ~ ":" ~ tag, values, content);
        }

        static UI5Element opCall(string tag, UI5Element[] content) {
            return Element(tag, null, content);
        }
    }

    mixin(createElement("ActionListItem"));
    mixin(createElement("ActionSheet"));
    mixin(createElement("App"));
    mixin(createElement("Avatar"));
    mixin(createElement("BadgeCustomData"));
    mixin(createElement("BadgeEnabler"));
    mixin(createElement("Bar"));
    mixin(createElement("BarInPageEnabler"));
    mixin(createElement("Breadcrumbs"));
    mixin(createElement("BusyDialog"));
    mixin(createElement("BusyIndicator"));
    mixin(createElement("Button"));
    mixin(createElement("Carousel"));
    mixin(createElement("CarouselLayout"));
    mixin(createElement("CheckBox"));
    mixin(createElement("ColorPalette"));
    mixin(createElement("ColorPalettePopover"));

    struct Column {
        static UI5Element opCall(string[string] values = null, UI5Element[] content = null) {
            return Element("Column", values, content);
        }

        static UI5Element opCall(UI5Element[] content) {
            return Element("Column", null, content);
        }

        static UI5Element opCall(string text) {
            return Column([Text(text)]);
        }
    }

    struct Columns {
        static UI5Element opCall(string[string] values = null, UI5Element[] content = null) {
            return Element("columns", values, content);
        }

        static UI5Element opCall(UI5Element[] content) {
            return Element("columns", null, content);
        }

        static UI5Element opCall(string[] cols) {
            return Columns(cols.map!(col => Element("Column", [Text(col)])).array);
        }
    }

    mixin(createElement("ColumnListItem"));
    mixin(createElement("ComboBox"));
    mixin(createElement("ComboBoxTextField"));
    mixin(createElement("CustomListItem"));
    mixin(createElement("CustomTreeItem"));
    mixin(createElement("DatePicker"));
    mixin(createElement("DateRangeSelection"));
    mixin(createElement("DateTimeField"));
    mixin(createElement("DateTimePicker"));
    mixin(createElement("Dialog"));
    mixin(createElement("DisplayListItem"));
    mixin(createElement("DraftIndicator"));
    mixin(createElement("DynamicDate"));
    mixin(createElement("DynamicDateFormat"));
    mixin(createElement("DynamicDateOption"));
    mixin(createElement("DynamicDateRange"));
    mixin(createElement("DynamicDateValueHelpUIType"));
    mixin(createElement("ExpandableText"));
    mixin(createElement("FacetFilter"));
    mixin(createElement("FacetFilterItem"));
    mixin(createElement("FacetFilterList"));
    mixin(createElement("FeedContent"));
    mixin(createElement("FeedInput"));
    mixin(createElement("FeedListItem"));
    mixin(createElement("FeedListItemAction"));
    mixin(createElement("FlexBox"));
    mixin(createElement("FlexItemData"));
    mixin(createElement("FormattedText"));
    mixin(createElement("GenericTag"));
    mixin(createElement("GenericTile"));
    mixin(createElement("GroupHeaderListItem"));
    mixin(createElement("GrowingEnablement"));
    mixin(createElement("HBox"));
    mixin(createElement("HeaderContainer"));
    mixin(createElement("IconTabBar"));
    mixin(createElement("IconTabFilter"));
    mixin(createElement("IconTabHeader"));
    mixin(createElement("IconTabSeparator"));
    mixin(createElement("IllustratedMessage"));
    mixin(createElement("Image"));
    mixin(createElement("ImageContent"));
    mixin(createElement("Input"));
    mixin(createElement("InputBase"));
    mixin(createElement("InputListItem"));
    mixin(createElementWithText("Label"));
    mixin(createElement("LightBox"));
    mixin(createElement("LightBoxItem"));
    mixin(createElement("Link"));
    mixin(createElement("LinkTileContent"));
    mixin(createElement("List"));
    mixin(createElement("ListBase"));
    mixin(createElement("ListItemBase"));
    mixin(createElement("MaskInput"));
    mixin(createElement("MaskInputRule"));
    mixin(createElement("Menu"));
    mixin(createElement("MenuButton"));
    mixin(createElement("MenuItem"));
    mixin(createElement("MessageItem"));
    mixin(createElement("MessagePopover"));
    mixin(createElement("MessageStrip"));
    mixin(createElement("MessageView"));
    mixin(createElement("MultiComboBox"));
    mixin(createElement("MultiInput"));
    mixin(createElement("NavContainer"));
    mixin(createElement("NewsContent"));
    mixin(createElement("NotificationList"));
    mixin(createElement("NotificationListBase"));
    mixin(createElement("NotificationListGroup"));
    mixin(createElement("NotificationListItem"));
    mixin(createElement("NumericContent"));
    mixin(createElement("ObjectAttribute"));
    mixin(createElement("ObjectHeader"));
    mixin(createElement("ObjectIdentifier"));
    mixin(createElement("ObjectListItem"));
    mixin(createElement("ObjectMarker"));
    mixin(createElement("ObjectNumber"));
    mixin(createElement("ObjectStatus"));
    mixin(createElement("OverflowToolbar"));
    mixin(createElement("OverflowToolbarButton"));
    mixin(createElement("OverflowToolbarLayoutData"));
    mixin(createElement("OverflowToolbarMenuButton"));
    mixin(createElement("OverflowToolbarToggleButton"));
    mixin(createElement("P13nConditionPanel"));
    mixin(createElement("P13nFilterItem"));
    mixin(createElement("P13nFilterPanel"));
    mixin(createElement("P13nItem"));
    mixin(createElement("P13nPanel"));
    mixin(createElement("Page"));
    mixin(createElement("Panel"));
    mixin(createElement("PDFViewer"));
    mixin(createElement("PlanningCalendar"));
    mixin(createElement("PlanningCalendarLegend"));
    mixin(createElement("PlanningCalendarRow"));
    mixin(createElement("PlanningCalendarView"));
    mixin(createElement("Popover"));
    mixin(createElement("ProgressIndicator"));
    mixin(createElement("PullToRefresh"));
    mixin(createElement("QuickView"));
    mixin(createElement("QuickViewBase"));
    mixin(createElement("QuickViewCard"));
    mixin(createElement("QuickViewGroup"));
    mixin(createElement("QuickViewGroupElement"));
    mixin(createElement("QuickViewPage"));
    mixin(createElement("RadioButton"));
    mixin(createElement("RadioButtonGroup"));
    mixin(createElement("RangeSlider"));
    mixin(createElement("RatingIndicator"));
    mixin(createElement("ResponsivePopover"));
    mixin(createElement("ResponsiveScale"));
    mixin(createElement("ScrollContainer"));
    mixin(createElement("SearchField"));
    mixin(createElement("SegmentedButton"));
    mixin(createElement("SegmentedButtonItem"));
    mixin(createElement("Select"));
    mixin(createElement("SelectDialog"));
    mixin(createElement("SelectDialogBase"));
    mixin(createElement("SelectionDetails"));
    mixin(createElement("SelectionDetailsFacade"));
    mixin(createElement("SelectionDetailsItem"));
    mixin(createElement("SelectionDetailsItemFacade"));
    mixin(createElement("SelectionDetailsItemLine"));
    mixin(createElement("SelectList"));
    mixin(createElement("Shell"));
    mixin(createElement("SinglePlanningCalendar"));
    mixin(createElement("SinglePlanningCalendarDayView"));
    mixin(createElement("SinglePlanningCalendarMonthView"));
    mixin(createElement("SinglePlanningCalendarView"));
    mixin(createElement("SinglePlanningCalendarWeekView"));
    mixin(createElement("SinglePlanningCalendarWorkWeekView"));
    mixin(createElement("Slider"));
    mixin(createElement("SliderTooltipBase"));
    mixin(createElement("SlideTile"));
    mixin(createElement("SplitApp"));
    mixin(createElement("SplitContainer"));
    mixin(createElement("StandardListItem"));
    mixin(createElement("StandardTreeItem"));
    mixin(createElement("StepInput"));
    mixin(createElement("SuggestionItem"));
    mixin(createElement("Switch"));
    mixin(createElement("TabContainer"));
    mixin(createElement("TabContainerItem"));
    mixin(createElement("Table"));
    mixin(createElement("TableSelectDialog"));
    mixin(createElementWithText("Text"));   
    mixin(createElement("TextArea"));   
    mixin(createElement("TileContent"));   
    mixin(createElement("TimePicker"));   
    mixin(createElement("TimePickerClocks"));   
    mixin(createElement("TimePickerInputs"));   
    mixin(createElement("TimePickerSliders"));   
    mixin(createElementWithText("Title"));   
    mixin(createElementWithText("ToggleButton"));   
    mixin(createElementWithText("Token"));   
    mixin(createElementWithText("Tokenizer"));   
    mixin(createElement("Toolbar")); 
    mixin(createElement("ToolbarLayoutData"));
    mixin(createElement("ToolbarSeparator"));
    mixin(createElement("ToolbarSpacer"));
    mixin(createElement("Tree"));
    mixin(createElement("TreeItemBase"));
    mixin(createElement("VariantItem"));
    mixin(createElement("VariantManagement"));
    mixin(createElement("VBox"));
    mixin(createElement("ViewSettingsCustomItem"));
    mixin(createElement("ViewSettingsCustomTab"));
    mixin(createElement("ViewSettingsDialog"));
    mixin(createElement("ViewSettingsFilterItem"));
    mixin(createElement("ViewSettingsItem"));
    mixin(createElement("WheelSlider"));
    mixin(createElement("WheelSliderContainer"));
    mixin(createElement("Wizard"));
    mixin(createElement("WizardStep"));

    // static SAPMLibrary instance() {
    //     if (_instance is null) {
    //         _instance = new SAPMLibrary();
    //     }
    //     return _instance;
    // }
}

auto Library() {
    return SAPMLibrary.instance();
}
///
unittest {
    SAPMLibrary m = new SAPMLibrary();
    SAPMLibrary.prefix = "";

    UI5Library x = new UI5Library();
    UI5Library.prefix = "x";

    writeln("\n --- SAP M Library ---");
    writeln(m.Element("MyElement", ["id": "testText"]).render());
    writeln(m.Text(["id": "x1"]).render());
    writeln(m.Text(["id": "x2"]).render());
    writeln(m.Text("text").render());
    writeln(m.Toolbar(["id": "toolbar1"]).render());
    writeln(m.Columns(["a", "b", "c"]).render());

    writeln("\n --- UI5 Library ---");
    writeln(x.Element("MyElement", ["id": "testText"]).render());

    // assert(lib.name == "SAP M Library");
    // assert(lib.prefix == "");
    // assert(lib.namespace == "sap.m");

    // UI5Element text = lib.Text(["id": "testText"], [new UI5Element("Span")]);
    // writeln(text.render);
    // assert(text.tag == "Text");
    // assert(text.attributes["id"] == "testText");
    // assert(text.children.length == 1);
    // assert(text.children[0].tag == "Span");
}
