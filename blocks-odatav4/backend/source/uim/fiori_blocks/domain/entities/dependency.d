/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.dependency;

@safe:

/// A directed dependency from one block to another block (complex type, no own identity in OData).
struct Dependency {
  string ID; /// Target block ID, e.g. "AB-02"
  string Name; /// Target block name, e.g. "Integration Gateway"
  string Type; /// e.g. "Uses API", "Requires DB", "Event Trigger"
  string Criticality; /// see `Criticality` enumeration
}
