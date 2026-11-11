/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.base;

import uim.fiori_blocks.domain.entities.dependency;

@safe:

/// Generic enterprise building block.
struct BaseBlock {
  enum entitySet = "BaseBlocks";
  enum idPrefix = "BB";

  string ID;
  string Name;
  string Responsible;
  string Version;
  string Date;
  string Description;
  string[] AdditionalInformation;
  Dependency[] DependsOn;
}
