/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.serialization;

/// Generic, reflection based JSON codec for plain structs.
/// Replaces the hand-written (and partly broken) toJson/fromJson methods of the former entities.
///
/// Supported member types: string, bool, integral, floating point, arrays and nested structs.
import std.conv : to, ConvException;
import std.traits : FieldNameTuple, isIntegral, isFloatingPoint, isSomeString;

import vibe.data.json : Json;

import uim.fiori_blocks.domain.exceptions : ValidationException;

@safe:

/// Encodes a value as Json.
Json encode(T)(auto ref const T value) {
  static if (isSomeString!T)
    return Json(value.to!string);
  else static if (is(T == bool) || isIntegral!T || isFloatingPoint!T)
    return Json(value);
  else static if (is(T : const(E)[], E)) {
    Json[] items;
    foreach (ref item; value)
      items ~= encode(item);
    return Json(items);
  } else static if (is(T == struct)) {
    auto result = Json.emptyObject;
    static foreach (name; FieldNameTuple!T)
      result[name] = encode(__traits(getMember, value, name));
    return result;
  } else
    static assert(0, "Unsupported type for JSON encoding: " ~ T.stringof);
}

/// Decodes a struct from a Json object. Missing members keep their default value.
T decode(T)(Json json) if (is(T == struct)) {
  T result;
  merge(result, json);
  return result;
}

/// Overwrites only the members of `target` that are present in `patch` (PATCH semantics).
/// Annotations ("@odata.etag") and unknown members are ignored.
void merge(T)(ref T target, Json patch, string path = "") if (is(T == struct)) {
  if (patch.type != Json.Type.object)
    throw new ValidationException("Expected a JSON object" ~ (path.length ? " for '" ~ path ~ "'" : ""));

  static foreach (name; FieldNameTuple!T) {
    {
      auto member = name in patch;
      if (member !is null && member.type != Json.Type.undefined)
        __traits(getMember, target, name) = decodeValue!(typeof(__traits(getMember, target, name)))(
          *member, path.length ? path ~ "/" ~ name : name);
    }
  }
}

/// Decodes a single value with lenient conversion (e.g. "true" -> bool, 42 -> "42").
T decodeValue(T)(Json json, string path) {
  if (json.type == Json.Type.null_ || json.type == Json.Type.undefined)
    return T.init;

  static if (isSomeString!T) {
    switch (json.type) {
    case Json.Type.string:
      return json.get!string.to!T;
    case Json.Type.int_, Json.Type.bigInt, Json.Type.float_, Json.Type.bool_:
      return json.toString.to!T;
    default:
      throw typeError(path, "string");
    }
  } else static if (is(T == bool)) {
    if (json.type == Json.Type.bool_)
      return json.get!bool;
    if (json.type == Json.Type.string && (json.get!string == "true" || json.get!string == "false"))
      return json.get!string == "true";
    throw typeError(path, "boolean");
  } else static if (isIntegral!T || isFloatingPoint!T) {
    try {
      switch (json.type) {
      case Json.Type.int_:
        return json.get!long.to!T;
      case Json.Type.float_:
        return json.get!double.to!T;
      case Json.Type.string:
        return json.get!string.to!T;
      default:
        break;
      }
    } catch (ConvException) {
    }
    throw typeError(path, "number");
  } else static if (is(T : E[], E)) {
    if (json.type != Json.Type.array)
      throw typeError(path, "array");
    T items;
    foreach (i, item; json.get!(Json[]))
      items ~= decodeValue!E(item, path ~ "[" ~ i.to!string ~ "]");
    return items;
  } else static if (is(T == struct)) {
    T result;
    merge(result, json, path);
    return result;
  } else
    static assert(0, "Unsupported type for JSON decoding: " ~ T.stringof);
}

private ValidationException typeError(string path, string expected) pure {
  return new ValidationException("Property '" ~ path ~ "' must be of type " ~ expected);
}

///
unittest {
  static struct Inner {
    string Name;
  }

  static struct Sample {
    string ID;
    bool Active = true;
    int Count;
    string[] Tags;
    Inner[] Items;
  }

  auto s = Sample("X-1", false, 3, ["a"], [Inner("i")]);
  auto json = encode(s);
  assert(json["ID"].get!string == "X-1");
  assert(json["Items"][0]["Name"].get!string == "i");
  assert(decode!Sample(json) == s);

  // PATCH: only present members change
  auto patched = s;
  merge(patched, Json(["Count": Json("7"), "@odata.etag": Json("W/1")]));
  assert(patched.Count == 7 && patched.ID == "X-1" && patched.Tags == ["a"]);

  bool failed;
  try
    merge(patched, Json(["Tags": Json("no-array")]));
  catch (ValidationException)
    failed = true;
  assert(failed);
}
