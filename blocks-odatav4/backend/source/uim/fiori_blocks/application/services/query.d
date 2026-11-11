/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.application.services.query;

/// Executes a `QuerySpec` (filter, search, sort, paging, projection) on Json documents.
import std.algorithm : canFind, filter, min, sort;
import std.array : array;
import std.string : toLower;

import vibe.data.json : Json;

import uim.fiori_blocks.application.dtos.query;

@safe:

QueryResult runQuery(Json[] documents, const ref QuerySpec spec, string keyProperty = "ID") {
  auto matches = documents;

  if (spec.filter !is null)
    matches = matches.filter!(d => spec.filter.matches(d)).array;

  if (spec.search.length) {
    auto needle = spec.search.toLower;
    matches = matches.filter!(d => containsText(d, needle)).array;
  }

  if (spec.orderBy.length) {
    auto keys = spec.orderBy.dup;
    matches = matches.dup;
    matches.sort!((a, b) => lessThan(a, b, keys));
  }

  QueryResult result;
  result.total = matches.length;

  auto from = min(cast(size_t)(spec.skip < 0 ? 0 : spec.skip), matches.length);
  auto to = spec.top < 0 ? matches.length : min(from + cast(size_t) spec.top, matches.length);
  matches = matches[from .. to];

  if (spec.select.length)
    foreach (doc; matches)
      result.items ~= project(doc, spec.select, keyProperty);
  else
    result.items = matches;
  return result;
}

/// Keeps only the selected top-level properties (the key is always kept).
Json project(Json document, const string[] properties, string keyProperty) {
  auto result = Json.emptyObject;
  foreach (string name, value; document.byKeyValue)
    if (name == keyProperty || properties.canFind(name) || properties.canFind("*"))
      result[name] = value;
  return result;
}

private bool containsText(Json value, string needle) {
  switch (value.type) {
  case Json.Type.string:
    return value.get!string.toLower.canFind(needle);
  case Json.Type.array:
    foreach (item; value.get!(Json[]))
      if (containsText(item, needle))
        return true;
    return false;
  case Json.Type.object:
    foreach (string _, item; value.byKeyValue)
      if (containsText(item, needle))
        return true;
    return false;
  default:
    return false;
  }
}

private bool lessThan(Json a, Json b, const SortKey[] keys) {
  foreach (key; keys) {
    auto path = new PathExpr(key.path);
    auto c = compareJson(path.eval(a, null), path.eval(b, null));
    if (c == incomparable) {
      // nulls first (ascending)
      auto aNull = path.eval(a, null).type == Json.Type.null_;
      auto bNull = path.eval(b, null).type == Json.Type.null_;
      if (aNull == bNull)
        continue;
      c = aNull ? -1 : 1;
    }
    if (c != 0)
      return key.descending ? c > 0 : c < 0;
  }
  return false;
}

///
unittest {
  auto docs = [
    Json(["ID": Json("1"), "Name": Json("Beta"), "Tag": Json("x")]),
    Json(["ID": Json("2"), "Name": Json("Alpha"), "Tag": Json("y")]),
    Json(["ID": Json("3"), "Name": Json("Gamma"), "Tag": Json("alpha-tag")])
  ];

  QuerySpec spec;
  spec.orderBy = [SortKey("Name", true)];
  spec.top = 2;
  spec.select = ["Name"];
  auto result = runQuery(docs, spec);
  assert(result.total == 3 && result.items.length == 2);
  assert(result.items[0]["Name"].get!string == "Gamma");
  assert("Tag" !in result.items[0] && "ID" in result.items[0]);

  QuerySpec search;
  search.search = "ALPHA";
  assert(runQuery(docs, search).total == 2);

  QuerySpec paged;
  paged.skip = 5;
  assert(runQuery(docs, paged).items.length == 0);
}
