/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.fiori_blocks.presentation.cli : runCli;

/// `blocks-odatav4 [serve]` starts the OData server, `blocks-odatav4 --help` lists all commands.
int main(string[] args) {
  return runCli(args);
}
