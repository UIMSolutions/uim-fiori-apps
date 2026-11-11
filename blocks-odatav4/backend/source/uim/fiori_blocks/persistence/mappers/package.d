/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.persistence.mappers;

/// Converters between stored JSON documents (records) and domain entities.
/// Records currently have the same shape as the entities; this is the single place to change
/// when the stored format diverges (renamed columns, schema versions ...).
import vibe.data.json : Json;

import uim.fiori_blocks.infrastructure.serialization : decode, encode;

@safe:

Json toRecord(T)(const ref T entity) {
  return encode(entity);
}

T fromRecord(T)(Json record) {
  return decode!T(record);
}
