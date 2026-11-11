/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.architecture;

import uim.fiori_blocks.domain.entities.dependency;

@safe:

/// Architecture building block (module / service / product view).
struct ArchitectureBlock {
  enum entitySet = "ArchitectureBlocks";
  enum idPrefix = "AB";

  string ID;
  string Name;
  string Responsible;
  string Version;
  string Modul;
  string Service;
  string Product;
  string Date;
  string Description;
  string AdditionalInfo;
  Dependency[] DependsOn;
}
