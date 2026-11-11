/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.gui;

/// GtkD desktop client. Compiled only with `dub build --config=desktop` (version `WithGui`),
/// so the server build (Cloud Foundry) needs no GTK libraries.
///
/// The GUI is a driving adapter like OData and CLI: it talks to the `ServiceCatalog` only.
version (WithGui) {
  public import uim.fiori_blocks.presentation.gui.window;
}
