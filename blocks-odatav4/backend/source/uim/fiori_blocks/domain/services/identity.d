/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.services.identity;

import std.algorithm : startsWith;
import std.conv : to, ConvException;
import std.format : format;

@safe:

/// Generates the next business key "<prefix>-<nn>" (e.g. "AB-03") from the existing keys.
/// Keys that do not follow the pattern are ignored.
string nextBusinessId(string prefix, const string[] existingIds, uint digits = 2) pure {
  ulong highest = 0;
  auto head = prefix ~ "-";
  foreach (id; existingIds) {
    if (!id.startsWith(head))
      continue;
    try {
      auto number = id[head.length .. $].to!ulong;
      if (number > highest)
        highest = number;
    } catch (ConvException) {
      // non-numeric suffix -> not part of the sequence
    }
  }
  return format("%s-%0*d", prefix, digits, highest + 1);
}

///
unittest {
  assert(nextBusinessId("AB", []) == "AB-01");
  assert(nextBusinessId("AB", ["AB-01", "AB-07", "ARCH-02", "AB-x"]) == "AB-08");
  assert(nextBusinessId("USR", ["USR-002"], 3) == "USR-003");
}
