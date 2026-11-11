/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.gui.window;

version (WithGui):

import std.algorithm : canFind;
import std.conv : to;
import std.format : format;

import vibe.data.json : Json, parseJsonString;

import gobject.c.types : GType;
import gtk.Box;
import gtk.Button;
import gtk.CellRendererText;
import gtk.CheckButton;
import gtk.Dialog;
import gtk.Entry;
import gtk.Grid;
import gtk.HeaderBar;
import gtk.Label;
import gtk.ListStore;
import gtk.Main;
import gtk.MainWindow;
import gtk.MessageDialog;
import gtk.Paned;
import gtk.ScrolledWindow;
import gtk.SearchEntry;
import gtk.Stack;
import gtk.StackSidebar;
import gtk.Statusbar;
import gtk.TextView;
import gtk.TreeIter;
import gtk.TreePath;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Widget;
import gtk.Window;
import gtk.c.types : GtkButtonsType, GtkDialogFlags, GtkMessageType, GtkOrientation, GtkPolicyType, ResponseType;

import uim.fiori_blocks.application;
import uim.fiori_blocks.composition : AppContext;

/// Opens the desktop client and runs the GTK main loop.
int runGui(AppContext context) @trusted {
  string[] args = ["blocks-odatav4"];
  Main.init(args);
  auto window = new BlocksWindow(context);
  window.showAll();
  Main.run();
  return 0;
}

/// Main window: entity sets in a sidebar, one table per set, CRUD toolbar in the header bar.
class BlocksWindow : MainWindow {
  private AppContext _context;
  private Stack _stack;
  private SearchEntry _search;
  private Statusbar _status;
  private EntityPage[string] _pages;

  this(AppContext context) {
    super("EA Building Blocks");
    _context = context;
    setDefaultSize(1180, 720);

    auto header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("EA Building Blocks");
    header.setSubtitle("Storage: " ~ context.storage.describe);
    setTitlebar(header);

    header.packStart(toolButton("list-add-symbolic", "Neu", (Button b) { editSelected(true); }));
    header.packStart(toolButton("document-edit-symbolic", "Bearbeiten", (Button b) { editSelected(false); }));
    header.packStart(toolButton("list-remove-symbolic", "Löschen", (Button b) { deleteSelected(); }));
    header.packEnd(toolButton("view-refresh-symbolic", "Aktualisieren", (Button b) { refresh(); }));

    _search = new SearchEntry();
    _search.setPlaceholderText("Suchen …");
    _search.addOnSearchChanged((SearchEntry e) { refresh(); });
    header.packEnd(_search);

    _stack = new Stack();
    foreach (service; context.catalog.all) {
      auto page = new EntityPage(service);
      page.view.addOnRowActivated((TreePath p, TreeViewColumn c, TreeView v) { editSelected(false); });
      _pages[service.name] = page;
      _stack.addTitled(page.scroller, service.name, service.name);
    }
    _stack.addOnNotify((ParamSpec, ObjectG) { refresh(); }, "visible-child-name");

    auto sidebar = new StackSidebar();
    sidebar.setStack(_stack);
    sidebar.setSizeRequest(200, -1);

    auto paned = new Paned(GtkOrientation.HORIZONTAL);
    paned.pack1(sidebar, false, false);
    paned.pack2(_stack, true, false);

    _status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(paned, true, true, 0);
    root.packEnd(_status, false, false, 0);
    add(root);

    addOnDestroy((Widget w) { Main.quit(); });
    refresh();
  }

  private EntityPage current() {
    auto name = _stack.getVisibleChildName();
    auto page = name in _pages;
    return page is null ? null : *page;
  }

  void refresh() {
    auto page = current();
    if (page is null)
      return;
    try {
      auto shown = page.reload(_search.getText());
      setStatus(format("%s: %s von %s Einträgen", page.service.name, shown, page.service.count));
    } catch (Exception e) {
      showError(e.msg);
    }
  }

  private void editSelected(bool create) {
    auto page = current();
    if (page is null)
      return;
    Json entity = Json.emptyObject;
    string id;
    if (!create) {
      id = page.selectedId();
      if (id.length == 0) {
        setStatus("Bitte zuerst einen Eintrag auswählen.");
        return;
      }
      entity = page.service.get(id);
    }

    auto dialog = new EntityDialog(this, page.service, entity, create);
    scope (exit)
      dialog.destroy();
    while (dialog.run() == ResponseType.OK) {
      try {
        auto data = dialog.collect();
        auto saved = create ? page.service.create(data) : page.service.patch(id, data);
        refresh();
        setStatus(format("%s('%s') gespeichert.", page.service.name, saved["ID"].get!string));
        return;
      } catch (Exception e) {
        showError(e.msg);
      }
    }
  }

  private void deleteSelected() {
    auto page = current();
    if (page is null)
      return;
    auto id = page.selectedId();
    if (id.length == 0) {
      setStatus("Bitte zuerst einen Eintrag auswählen.");
      return;
    }
    auto confirm = new MessageDialog(this, GtkDialogFlags.MODAL, GtkMessageType.QUESTION, GtkButtonsType.YES_NO,
      format("%s('%s') wirklich löschen?", page.service.name, id));
    auto answer = confirm.run();
    confirm.destroy();
    if (answer != ResponseType.YES)
      return;
    try {
      page.service.remove(id);
      refresh();
      setStatus(format("%s('%s') gelöscht.", page.service.name, id));
    } catch (Exception e) {
      showError(e.msg);
    }
  }

  private void setStatus(string text) {
    _status.removeAll(0);
    _status.push(0, text);
  }

  private void showError(string message) {
    auto dialog = new MessageDialog(this, GtkDialogFlags.MODAL, GtkMessageType.ERROR, GtkButtonsType.CLOSE, message);
    dialog.run();
    dialog.destroy();
  }

  private static Button toolButton(string icon, string tooltip, void delegate(Button) action) {
    auto button = new Button(icon, GtkIconSize.BUTTON);
    button.setTooltipText(tooltip);
    button.addOnClicked(action);
    return button;
  }
}

import gobject.ParamSpec : ParamSpec;
import gobject.ObjectG : ObjectG;
import gtk.c.types : GtkIconSize;

/// Table of one entity set. All columns are text; collections show their item count.
class EntityPage {
  IEntitySetService service;
  ScrolledWindow scroller;
  TreeView view;
  private ListStore _store;
  private string[] _columns;

  this(IEntitySetService service) {
    this.service = service;
    foreach (p; service.properties)
      _columns ~= p.name;

    GType[] types;
    foreach (_; _columns)
      types ~= GType.STRING;
    _store = new ListStore(types);

    view = new TreeView(_store);
    view.setSearchColumn(0);
    foreach (i, name; _columns) {
      auto renderer = new CellRendererText();
      auto column = new TreeViewColumn(name, renderer, "text", cast(int) i);
      column.setResizable(true);
      column.setSortColumnId(cast(int) i);
      column.setMaxWidth(320);
      view.appendColumn(column);
    }

    scroller = new ScrolledWindow();
    scroller.setPolicy(GtkPolicyType.AUTOMATIC, GtkPolicyType.AUTOMATIC);
    scroller.add(view);
  }

  /// Reloads the table, filtered by the free text search. Returns the number of rows.
  size_t reload(string search) {
    QuerySpec spec;
    spec.search = search;
    auto result = service.query(spec);
    _store.clear();
    foreach (item; result.items) {
      TreeIter iter;
      _store.append(iter);
      foreach (i, name; _columns) {
        auto value = name in item;
        string text;
        if (value !is null)
          text = value.type == Json.Type.array ? format("[%s]", value.length) : asString(*value);
        _store.setValue(iter, cast(int) i, text);
      }
    }
    return result.items.length;
  }

  string selectedId() {
    auto iter = view.getSelectedIter();
    return iter is null ? "" : iter.getValueString(0);
  }
}

/// Form for creating / editing an entity, generated from the property metadata.
class EntityDialog : Dialog {
  private IEntitySetService _service;
  private Entry[string] _entries;
  private CheckButton[string] _checks;
  private TextView[string] _texts;

  this(Window parent, IEntitySetService service, Json entity, bool create) {
    super(format("%s %s", service.typeName, create ? "anlegen" : "bearbeiten"), parent,
      GtkDialogFlags.MODAL | GtkDialogFlags.DESTROY_WITH_PARENT,
      ["Abbrechen", "Speichern"], [ResponseType.CANCEL, ResponseType.OK]);
    _service = service;
    setDefaultSize(560, -1);
    setDefaultResponse(ResponseType.OK);

    auto grid = new Grid();
    grid.setRowSpacing(6);
    grid.setColumnSpacing(12);
    grid.setBorderWidth(12);

    int row;
    foreach (p; service.properties) {
      auto label = new Label(p.name);
      label.setXalign(1);
      grid.attach(label, 0, row, 1, 1);
      auto value = p.name in entity;

      if (p.isScalar && p.kind == PrimitiveKind.boolean) {
        auto check = new CheckButton();
        check.setActive(value is null ? true : value.type == Json.Type.bool_ && value.get!bool);
        _checks[p.name] = check;
        grid.attach(check, 1, row, 1, 1);
      } else if (p.isScalar) {
        auto entry = new Entry();
        entry.setHexpand(true);
        entry.setActivatesDefault(true);
        if (value !is null)
          entry.setText(asString(*value));
        if (p.key) {
          entry.setSensitive(create);
          if (create)
            entry.setPlaceholderText("leer = automatisch");
        }
        _entries[p.name] = entry;
        grid.attach(entry, 1, row, 1, 1);
      } else {
        auto text = new TextView();
        text.setMonospace(true);
        text.getBuffer().setText(value is null ? "[]" : value.toPrettyString);
        auto scroll = new ScrolledWindow();
        scroll.setPolicy(GtkPolicyType.AUTOMATIC, GtkPolicyType.AUTOMATIC);
        scroll.setSizeRequest(-1, 110);
        scroll.setHexpand(true);
        scroll.add(text);
        _texts[p.name] = text;
        grid.attach(scroll, 1, row, 1, 1);
      }
      row++;
    }

    getContentArea().packStart(grid, true, true, 0);
    showAll();
  }

  /// Builds the JSON payload from the form (throws on invalid JSON in collection fields).
  Json collect() {
    auto data = Json.emptyObject;
    foreach (p; _service.properties) {
      if (auto entry = p.name in _entries) {
        if (p.key && !entry.getSensitive())
          continue;
        data[p.name] = entry.getText();
      } else if (auto check = p.name in _checks) {
        data[p.name] = check.getActive();
      } else if (auto text = p.name in _texts) {
        auto json = parseJsonString(text.getBuffer().getText(), p.name);
        if (json.type != Json.Type.array)
          throw new Exception(p.name ~ " muss ein JSON-Array sein");
        data[p.name] = json;
      }
    }
    return data;
  }
}
