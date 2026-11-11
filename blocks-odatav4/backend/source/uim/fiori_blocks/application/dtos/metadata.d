/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.application.dtos.metadata;

/// Structural description of entity types, derived at compile time from the domain structs.
/// Used to generate the OData $metadata document, CLI tables and GUI forms.
import std.traits : FieldNameTuple, isIntegral, isFloatingPoint, isSomeString;

@safe:

/// Primitive kinds of a property (mapped to Edm types by the OData adapter).
enum PrimitiveKind {
  string_,
  boolean,
  int32,
  int64,
  double_,
  complex
}

struct PropertyInfo {
  string name;
  PrimitiveKind kind;
  bool collection;
  string complexType; /// type name if kind == complex
  bool key;

  /// Simple single-valued property (string, number, bool).
  bool isScalar() const pure nothrow {
    return !collection && kind != PrimitiveKind.complex;
  }
}

struct TypeInfo_ {
  string name;
  PropertyInfo[] properties;
}

/// Properties of struct `T` in declaration order.
PropertyInfo[] propertiesOf(T)() pure {
  PropertyInfo[] result;
  static foreach (name; FieldNameTuple!T) {
    {
      alias M = typeof(__traits(getMember, T, name));
      static if (is(M : E[], E) && !isSomeString!M)
        result ~= describe!E(name, true);
      else
        result ~= describe!M(name, false);
    }
  }
  return result;
}

/// Complex (struct) types used by members of `T`, recursively.
TypeInfo_[] complexTypesOf(T)() pure {
  TypeInfo_[] result;
  static foreach (name; FieldNameTuple!T) {
    {
      alias M = typeof(__traits(getMember, T, name));
      static if (is(M : E[], E) && is(E == struct))
        result ~= TypeInfo_(E.stringof, propertiesOf!E) ~ complexTypesOf!E;
      else static if (is(M == struct))
        result ~= TypeInfo_(M.stringof, propertiesOf!M) ~ complexTypesOf!M;
    }
  }
  return result;
}

private PropertyInfo describe(M)(string name, bool collection) pure {
  PropertyInfo info;
  info.name = name;
  info.collection = collection;
  info.key = name == "ID" && !collection;
  static if (isSomeString!M)
    info.kind = PrimitiveKind.string_;
  else static if (is(M == bool))
    info.kind = PrimitiveKind.boolean;
  else static if (isIntegral!M && M.sizeof <= 4)
    info.kind = PrimitiveKind.int32;
  else static if (isIntegral!M)
    info.kind = PrimitiveKind.int64;
  else static if (isFloatingPoint!M)
    info.kind = PrimitiveKind.double_;
  else static if (is(M == struct)) {
    info.kind = PrimitiveKind.complex;
    info.complexType = M.stringof;
  } else
    static assert(0, "Unsupported property type " ~ M.stringof);
  return info;
}

///
unittest {
  import uim.fiori_blocks.domain.entities;

  auto props = propertiesOf!BaseBlock;
  assert(props[0].name == "ID" && props[0].key);
  assert(props[6].name == "AdditionalInformation" && props[6].collection && props[6].kind == PrimitiveKind.string_);
  assert(props[7].complexType == "Dependency" && props[7].collection);
  assert(complexTypesOf!BaseBlock[0].name == "Dependency");
  assert(propertiesOf!User[4].kind == PrimitiveKind.boolean);
}
