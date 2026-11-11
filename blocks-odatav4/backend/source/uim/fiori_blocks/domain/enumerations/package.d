/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.enumerations;

/// Business enumerations & status values.
/// The entities keep these values as strings (OData Edm.String), the enums define the allowed values.
@safe:

/// Roles of application users.
enum UserRole : string {
  administrator = "Administrator",
  editor = "Editor",
  viewer = "Viewer"
}

/// Criticality of a dependency between blocks.
enum Criticality : string {
  high = "High",
  medium = "Medium",
  low = "Low"
}

/// Lifecycle status of an interface block.
enum BlockStatus : string {
  planned = "Planned",
  inProgress = "In Progress",
  active = "Active",
  deprecated_ = "Deprecated"
}

/// Returns true if `value` is one of the values of enum `E` (empty values are allowed).
bool isAllowedValue(E)(string value) pure nothrow {
  if (value.length == 0)
    return true;
  static foreach (member; __traits(allMembers, E)) {
    if (value == cast(string) __traits(getMember, E, member))
      return true;
  }
  return false;
}

/// Comma separated list of all values of enum `E` (for error messages).
string allowedValues(E)() pure {
  string result;
  static foreach (i, member; __traits(allMembers, E)) {
    static if (i > 0)
      result ~= ", ";
    result ~= cast(string) __traits(getMember, E, member);
  }
  return result;
}

///
unittest {
  assert(isAllowedValue!UserRole("Viewer"));
  assert(!isAllowedValue!UserRole("Root"));
  assert(isAllowedValue!UserRole(""));
  assert(allowedValues!Criticality == "High, Medium, Low");
}
