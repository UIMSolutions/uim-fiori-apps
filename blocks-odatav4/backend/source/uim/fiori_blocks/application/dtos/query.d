/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.application.dtos.query;

/// Protocol independent query model: filter expression tree, sorting, paging, projection.
/// The OData adapter parses `$filter`, `$orderby` ... into this model; the CLI reuses the same parser.
import std.algorithm : all, any, canFind, endsWith, map, startsWith;
import std.array : array, join, split;
import std.conv : to;
import std.math : isNaN;
import std.string : indexOf, strip, toLower, toUpper;

import vibe.data.json : Json;

@safe:

/// Thrown for semantically invalid queries (unknown function, wrong argument count ...).
class QueryException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// Variables bound by lambda operators (any/all).
alias Scope = Json[string];

abstract class FilterExpr {
  abstract Json eval(Json entity, Scope variables) const;

  final bool matches(Json entity) const {
    return isTrue(eval(entity, null));
  }
}

/// A literal value: string, number, boolean or null.
final class LiteralExpr : FilterExpr {
  Json value;

  this(Json value) {
    this.value = value;
  }

  override Json eval(Json, Scope) const {
    return value;
  }
}

/// A property path "Name" or "a/b"; the first segment may be a lambda variable.
final class PathExpr : FilterExpr {
  string[] segments;

  this(string path) {
    segments = path.split("/");
  }

  override Json eval(Json entity, Scope variables) const {
    Json current = entity;
    const(string)[] rest = segments;
    if (auto bound = segments[0] in variables) {
      current = *bound;
      rest = segments[1 .. $];
    } else if (segments[0] == "$it") {
      rest = segments[1 .. $];
    }
    foreach (segment; rest) {
      if (current.type != Json.Type.object)
        return Json(null);
      auto next = segment in current;
      if (next is null)
        return Json(null);
      current = *next;
    }
    return current;
  }
}

enum BinaryOp : string {
  eq = "eq",
  ne = "ne",
  gt = "gt",
  ge = "ge",
  lt = "lt",
  le = "le",
  and = "and",
  or = "or"
}

final class BinaryExpr : FilterExpr {
  BinaryOp op;
  FilterExpr left, right;

  this(BinaryOp op, FilterExpr left, FilterExpr right) {
    this.op = op;
    this.left = left;
    this.right = right;
  }

  override Json eval(Json entity, Scope variables) const {
    final switch (op) {
    case BinaryOp.and:
      return Json(isTrue(left.eval(entity, variables)) && isTrue(right.eval(entity, variables)));
    case BinaryOp.or:
      return Json(isTrue(left.eval(entity, variables)) || isTrue(right.eval(entity, variables)));
    case BinaryOp.eq:
      return Json(compareJson(left.eval(entity, variables), right.eval(entity, variables)) == 0);
    case BinaryOp.ne:
      return Json(compareJson(left.eval(entity, variables), right.eval(entity, variables)) != 0);
    case BinaryOp.gt, BinaryOp.ge, BinaryOp.lt, BinaryOp.le:
      auto c = compareJson(left.eval(entity, variables), right.eval(entity, variables));
      if (c == incomparable)
        return Json(false);
      return Json(op == BinaryOp.gt ? c > 0 : op == BinaryOp.ge ? c >= 0 : op == BinaryOp.lt ? c < 0 : c <= 0);
    }
  }
}

final class NotExpr : FilterExpr {
  FilterExpr operand;

  this(FilterExpr operand) {
    this.operand = operand;
  }

  override Json eval(Json entity, Scope variables) const {
    return Json(!isTrue(operand.eval(entity, variables)));
  }
}

/// `left in (v1, v2, ...)`
final class InExpr : FilterExpr {
  FilterExpr left;
  FilterExpr[] candidates;

  this(FilterExpr left, FilterExpr[] candidates) {
    this.left = left;
    this.candidates = candidates;
  }

  override Json eval(Json entity, Scope variables) const {
    auto value = left.eval(entity, variables);
    foreach (candidate; candidates)
      if (compareJson(value, candidate.eval(entity, variables)) == 0)
        return Json(true);
    return Json(false);
  }
}

/// `collection/any(v: predicate)` and `collection/all(v: predicate)`
final class LambdaExpr : FilterExpr {
  PathExpr collection;
  string variable;
  FilterExpr predicate; /// null for `any()` without arguments
  bool isAll;

  this(PathExpr collection, string variable, FilterExpr predicate, bool isAll) {
    this.collection = collection;
    this.variable = variable;
    this.predicate = predicate;
    this.isAll = isAll;
  }

  override Json eval(Json entity, Scope variables) const {
    auto items = collection.eval(entity, variables);
    if (items.type != Json.Type.array)
      return Json(isAll);
    if (predicate is null)
      return Json(items.length > 0);

    Scope inner;
    foreach (k, v; variables)
      inner[k] = v;
    bool test(Json item) {
      inner[variable] = item;
      return isTrue(predicate.eval(entity, inner));
    }

    auto list = items.get!(Json[]);
    return Json(isAll ? list.all!(i => test(i)) : list.any!(i => test(i)));
  }
}

/// Built-in OData string functions.
final class FunctionExpr : FilterExpr {
  string name;
  FilterExpr[] args;

  this(string name, FilterExpr[] args) {
    this.name = name.toLower;
    this.args = args;
    auto expected = arity(this.name);
    if (expected.length == 0)
      throw new QueryException("Unsupported function '" ~ name ~ "'");
    if (!expected.canFind(args.length))
      throw new QueryException("Function '" ~ name ~ "' expects " ~ expected.map!(n => n.to!string)
          .join(" or ") ~ " argument(s)");
  }

  private static size_t[] arity(string fn) pure {
    switch (fn) {
    case "contains", "startswith", "endswith", "indexof", "concat":
      return [2];
    case "tolower", "toupper", "trim", "length":
      return [1];
    case "substring":
      return [2, 3];
    default:
      return null;
    }
  }

  override Json eval(Json entity, Scope variables) const {
    auto values = args.map!(a => a.eval(entity, variables)).array;
    auto s0 = asString(values[0]);
    switch (name) {
    case "contains":
      return Json(s0.indexOf(asString(values[1])) >= 0);
    case "startswith":
      return Json(s0.startsWith(asString(values[1])));
    case "endswith":
      return Json(s0.endsWith(asString(values[1])));
    case "indexof":
      return Json(cast(long) s0.indexOf(asString(values[1])));
    case "concat":
      return Json(s0 ~ asString(values[1]));
    case "tolower":
      return Json(s0.toLower);
    case "toupper":
      return Json(s0.toUpper);
    case "trim":
      return Json(s0.strip);
    case "length":
      return values[0].type == Json.Type.array ? Json(cast(long) values[0].length) : Json(cast(long) s0.length);
    case "substring":
      auto start = cast(size_t) clamp(values[1], s0.length);
      auto end = values.length > 2 ? start + cast(size_t) clamp(values[2], s0.length - start) : s0.length;
      return Json(s0[start .. end]);
    default:
      assert(0);
    }
  }

  private static long clamp(Json v, size_t max) {
    long n = v.type == Json.Type.int_ ? v.get!long : 0;
    return n < 0 ? 0 : n > max ? max : n;
  }
}

/// Sort criterion of $orderby.
struct SortKey {
  string path;
  bool descending;
}

/// Complete query on an entity set.
struct QuerySpec {
  FilterExpr filter; /// null = no filter
  SortKey[] orderBy;
  long top = -1; /// -1 = unlimited
  long skip = 0;
  string[] select; /// empty = all properties
  string search; /// free text search over all string properties
  bool count; /// include the total count
}

/// Result of a query: one page of items plus the total number of matches.
struct QueryResult {
  Json[] items;
  size_t total;
}

// ---- value helpers ----

enum int incomparable = int.min;

bool isTrue(Json value) {
  return value.type == Json.Type.bool_ && value.get!bool;
}

string asString(Json value) {
  switch (value.type) {
  case Json.Type.string:
    return value.get!string;
  case Json.Type.null_, Json.Type.undefined:
    return "";
  default:
    return value.toString;
  }
}

private bool isNumber(Json value) {
  return value.type == Json.Type.int_ || value.type == Json.Type.float_ || value.type == Json.Type.bigInt;
}

private double toDouble(Json value) @trusted {
  return value.type == Json.Type.float_ ? value.get!double : value.to!double;
}

/// Three-way comparison of two Json values (`incomparable` for mismatching types).
int compareJson(Json a, Json b) @safe {
  auto aNull = a.type == Json.Type.null_ || a.type == Json.Type.undefined;
  auto bNull = b.type == Json.Type.null_ || b.type == Json.Type.undefined;
  if (aNull || bNull)
    return aNull && bNull ? 0 : incomparable;
  if (isNumber(a) && isNumber(b)) {
    auto x = toDouble(a), y = toDouble(b);
    return x < y ? -1 : x > y ? 1 : 0;
  }
  if (a.type == Json.Type.string && b.type == Json.Type.string) {
    auto x = a.get!string, y = b.get!string;
    return x < y ? -1 : x > y ? 1 : 0;
  }
  if (a.type == Json.Type.bool_ && b.type == Json.Type.bool_)
    return cast(int) a.get!bool - cast(int) b.get!bool;
  return incomparable;
}

///
unittest {
  auto entity = Json([
    "Name": Json("Domain Core"),
    "Active": Json(true),
    "Size": Json(3),
    "DependsOn": Json([Json(["Criticality": Json("High")]), Json(["Criticality": Json("Low")])])
  ]);

  auto nameEq = new BinaryExpr(BinaryOp.eq, new PathExpr("Name"), new LiteralExpr(Json("Domain Core")));
  assert(nameEq.matches(entity));

  auto containsCore = new FunctionExpr("contains", [new FunctionExpr("tolower", [new PathExpr("Name")]), new LiteralExpr(Json("core"))]);
  assert(containsCore.matches(entity));

  auto sizeGt = new BinaryExpr(BinaryOp.gt, new PathExpr("Size"), new LiteralExpr(Json(2.5)));
  assert(sizeGt.matches(entity));

  auto anyHigh = new LambdaExpr(new PathExpr("DependsOn"), "d",
    new BinaryExpr(BinaryOp.eq, new PathExpr("d/Criticality"), new LiteralExpr(Json("High"))), false);
  auto allHigh = new LambdaExpr(new PathExpr("DependsOn"), "d",
    new BinaryExpr(BinaryOp.eq, new PathExpr("d/Criticality"), new LiteralExpr(Json("High"))), true);
  assert(anyHigh.matches(entity) && !allHigh.matches(entity));

  assert(new InExpr(new PathExpr("Size"), [new LiteralExpr(Json(1)), new LiteralExpr(Json(3))]).matches(entity));
  assert(!new BinaryExpr(BinaryOp.gt, new PathExpr("Missing"), new LiteralExpr(Json(1))).matches(entity));
}
