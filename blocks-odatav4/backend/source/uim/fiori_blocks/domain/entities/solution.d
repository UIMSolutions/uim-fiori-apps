/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.solution;

import uim.fiori_blocks.domain.entities.dependency;

@safe:

/// Solution building block with a validity period.
struct SolutionBlock {
  enum entitySet = "SolutionBlocks";
  enum idPrefix = "SB";

  string ID;
  string Name;
  string Title;
  string Description;
  string ValidFrom; /// ISO date (YYYY-MM-DD)
  string ValidUntil; /// ISO date (YYYY-MM-DD)
  string Version;
  string Date;
  string AdditionalInfo;
  string Responsibles;
  Dependency[] DependsOnSolutionBlocks;
}
