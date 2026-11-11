/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.interface_;

@safe:

/// Interface building block (API, file transfer, messaging ...).
struct InterfaceBlock {
  enum entitySet = "InterfaceBlocks";
  enum idPrefix = "IF";

  string ID;
  string Name;
  string Type;
  string Description;
  string Status; /// see `BlockStatus` enumeration
}
