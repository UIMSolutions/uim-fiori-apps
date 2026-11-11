/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.parser;

/// Parser for the OData v4 system query options:
/// $filter, $orderby, $select, $top, $skip, $count, $search ($expand is accepted and ignored,
/// complex properties are always returned inline).
///
/// Supported $filter grammar:
///   expr     := or
///   or       := and ("or" and)*
///   and      := not ("and" not)*
///   not      := "not" not | compare
///   compare  := primary (("eq"|"ne"|"gt"|"ge"|"lt"|"le") primary | "in" "(" list ")")?
///   primary  := "(" expr ")" | literal | function "(" args ")" | path ["/any(v:expr)" | "/all(v:expr)"]
import std.algorithm : canFind, map;
import std.array : array, split;
import std.ascii : isAlpha, isAlphaNum, isDigit, isWhite;
import std.conv : to, ConvException;
import std.string : strip, toLower;

import vibe.data.json : Json;

import uim.fiori_blocks.application.dtos.query;
import uim.fiori_blocks.presentation.odata.errors;

@safe:

/// Builds a `QuerySpec` from decoded query parameters.
QuerySpec parseQueryOptions(const string[string] params) {
  QuerySpec spec;
  if (auto v = "$filter" in params)
    if ((*v).strip.length)
      spec.filter = parseFilter(*v);
  if (auto v = "$orderby" in params)
    spec.orderBy = parseOrderBy(*v);
  if (auto v = "$select" in params)
    spec.select = parseSelect(*v);
  if (auto v = "$top" in params)
    spec.top = parseNonNegative("$top", *v);
  if (auto v = "$skip" in params)
    spec.skip = parseNonNegative("$skip", *v);
  if (auto v = "$count" in params) {
    auto value = (*v).strip.toLower;
    if (value != "true" && value != "false")
      throw badRequest("$count must be true or false");
    spec.count = value == "true";
  }
  if (auto v = "$search" in params)
    spec.search = unquote((*v).strip);
  return spec;
}

SortKey[] parseOrderBy(string text) {
  SortKey[] keys;
  foreach (part; text.split(",")) {
    auto words = part.strip.split(" ").map!(w => w.strip).array;
    if (words.length == 0 || words[0].length == 0)
      continue;
    if (words.length > 2 || (words.length == 2 && !["asc", "desc"].canFind(words[1].toLower)))
      throw badRequest("Invalid $orderby item '" ~ part.strip ~ "'");
    keys ~= SortKey(words[0], words.length == 2 && words[1].toLower == "desc");
  }
  return keys;
}

string[] parseSelect(string text) {
  string[] result;
  foreach (part; text.split(",")) {
    auto name = part.strip;
    // "DependsOn/Name" selects the complex property as a whole
    if (name.canFind("/"))
      name = name.split("/")[0];
    if (name.length && !result.canFind(name))
      result ~= name;
  }
  return result;
}

private long parseNonNegative(string option, string text) {
  try {
    auto value = text.strip.to!long;
    if (value >= 0)
      return value;
  } catch (ConvException) {
  }
  throw badRequest(option ~ " must be a non-negative integer");
}

private string unquote(string text) pure {
  return text.length >= 2 && text[0] == '"' && text[$ - 1] == '"' ? text[1 .. $ - 1] : text;
}

// ---------------------------------------------------------------------------------------------
// $filter
// ---------------------------------------------------------------------------------------------

FilterExpr parseFilter(string text) {
  try {
    auto parser = FilterParser(tokenize(text));
    auto expr = parser.parseOr();
    if (!parser.atEnd)
      throw badRequest("Unexpected '" ~ parser.peek.text ~ "' in $filter");
    return expr;
  } catch (QueryException e) {
    throw badRequest(e.msg);
  }
}

private enum TokenKind {
  identifier,
  string_,
  number,
  open,
  close,
  comma,
  colon
}

private struct Token {
  TokenKind kind;
  string text;
}

private Token[] tokenize(string text) {
  Token[] tokens;
  size_t i;
  while (i < text.length) {
    auto c = text[i];
    if (isWhite(c)) {
      i++;
    } else if (c == '(') {
      tokens ~= Token(TokenKind.open, "(");
      i++;
    } else if (c == ')') {
      tokens ~= Token(TokenKind.close, ")");
      i++;
    } else if (c == ',') {
      tokens ~= Token(TokenKind.comma, ",");
      i++;
    } else if (c == ':') {
      tokens ~= Token(TokenKind.colon, ":");
      i++;
    } else if (c == '\'') {
      // string literal, '' escapes a quote
      string value;
      i++;
      while (true) {
        if (i >= text.length)
          throw badRequest("Unterminated string literal in $filter");
        if (text[i] == '\'') {
          if (i + 1 < text.length && text[i + 1] == '\'') {
            value ~= '\'';
            i += 2;
            continue;
          }
          i++;
          break;
        }
        value ~= text[i++];
      }
      tokens ~= Token(TokenKind.string_, value);
    } else if (isDigit(c) || (c == '-' && i + 1 < text.length && isDigit(text[i + 1]))) {
      auto start = i++;
      while (i < text.length && (isDigit(text[i]) || text[i] == '.'))
        i++;
      tokens ~= Token(TokenKind.number, text[start .. i]);
    } else if (isAlpha(c) || c == '_' || c == '$') {
      auto start = i++;
      while (i < text.length && (isAlphaNum(text[i]) || text[i] == '_' || text[i] == '/' || text[i] == '.'))
        i++;
      tokens ~= Token(TokenKind.identifier, text[start .. i]);
    } else {
      throw badRequest("Unexpected character '" ~ c ~ "' in $filter");
    }
  }
  return tokens;
}

private struct FilterParser {
  Token[] tokens;
  size_t pos;

  bool atEnd() const {
    return pos >= tokens.length;
  }

  Token peek() const {
    return atEnd ? Token(TokenKind.close, "<end>") : tokens[pos];
  }

  bool peekKeyword(string keyword) const {
    return !atEnd && tokens[pos].kind == TokenKind.identifier && tokens[pos].text.toLower == keyword;
  }

  Token expect(TokenKind kind, string what) {
    if (atEnd || tokens[pos].kind != kind)
      throw badRequest("Expected " ~ what ~ " in $filter but found '" ~ peek.text ~ "'");
    return tokens[pos++];
  }

  FilterExpr parseOr() {
    auto left = parseAnd();
    while (peekKeyword("or")) {
      pos++;
      left = new BinaryExpr(BinaryOp.or, left, parseAnd());
    }
    return left;
  }

  FilterExpr parseAnd() {
    auto left = parseNot();
    while (peekKeyword("and")) {
      pos++;
      left = new BinaryExpr(BinaryOp.and, left, parseNot());
    }
    return left;
  }

  FilterExpr parseNot() {
    if (peekKeyword("not")) {
      pos++;
      return new NotExpr(parseNot());
    }
    return parseCompare();
  }

  FilterExpr parseCompare() {
    auto left = parsePrimary();
    static immutable ops = ["eq", "ne", "gt", "ge", "lt", "le"];
    if (!atEnd && tokens[pos].kind == TokenKind.identifier) {
      auto word = tokens[pos].text.toLower;
      if (ops.canFind(word)) {
        pos++;
        return new BinaryExpr(cast(BinaryOp) word, left, parsePrimary());
      }
      if (word == "in") {
        pos++;
        expect(TokenKind.open, "'('");
        FilterExpr[] candidates = [parsePrimary()];
        while (!atEnd && tokens[pos].kind == TokenKind.comma) {
          pos++;
          candidates ~= parsePrimary();
        }
        expect(TokenKind.close, "')'");
        return new InExpr(left, candidates);
      }
    }
    return left;
  }

  FilterExpr parsePrimary() {
    if (atEnd)
      throw badRequest("Unexpected end of $filter");
    auto token = tokens[pos++];
    final switch (token.kind) {
    case TokenKind.open:
      auto inner = parseOr();
      expect(TokenKind.close, "')'");
      return inner;
    case TokenKind.string_:
      return new LiteralExpr(Json(token.text));
    case TokenKind.number:
      return new LiteralExpr(token.text.canFind('.') ? Json(token.text.to!double) : Json(token.text.to!long));
    case TokenKind.identifier:
      return parseIdentifier(token.text);
    case TokenKind.close, TokenKind.comma, TokenKind.colon:
      throw badRequest("Unexpected '" ~ token.text ~ "' in $filter");
    }
  }

  FilterExpr parseIdentifier(string text) {
    switch (text.toLower) {
    case "true":
      return new LiteralExpr(Json(true));
    case "false":
      return new LiteralExpr(Json(false));
    case "null":
      return new LiteralExpr(Json(null));
    default:
      break;
    }

    // lambda operator: path/any(v: expr) or path/all(v: expr)
    foreach (op; ["/any", "/all"]) {
      if (text.length > op.length && text[$ - op.length .. $].toLower == op && !atEnd && tokens[pos].kind == TokenKind.open) {
        pos++;
        auto collection = new PathExpr(text[0 .. $ - op.length]);
        if (!atEnd && tokens[pos].kind == TokenKind.close) {
          pos++;
          return new LambdaExpr(collection, "", null, op == "/all");
        }
        auto variable = expect(TokenKind.identifier, "lambda variable").text;
        expect(TokenKind.colon, "':'");
        auto predicate = parseOr();
        expect(TokenKind.close, "')'");
        return new LambdaExpr(collection, variable, predicate, op == "/all");
      }
    }

    // function call
    if (!atEnd && tokens[pos].kind == TokenKind.open) {
      pos++;
      FilterExpr[] args;
      if (!atEnd && tokens[pos].kind != TokenKind.close) {
        args ~= parseOr();
        while (!atEnd && tokens[pos].kind == TokenKind.comma) {
          pos++;
          args ~= parseOr();
        }
      }
      expect(TokenKind.close, "')'");
      return new FunctionExpr(text, args);
    }
    return new PathExpr(text);
  }
}

///
unittest {
  auto e = Json([
    "Name": Json("O'Neil Core"),
    "Version": Json("1.0"),
    "Active": Json(true),
    "DependsOn": Json([Json(["Criticality": Json("High")])])
  ]);
  assert(parseFilter("Name eq 'O''Neil Core'").matches(e));
  assert(parseFilter("contains(tolower(Name),'core') and Active eq true").matches(e));
  assert(parseFilter("not (Version eq '2.0') or Name eq 'x'").matches(e));
  assert(parseFilter("DependsOn/any(d:d/Criticality eq 'High')").matches(e));
  assert(!parseFilter("DependsOn/all(d:d/Criticality eq 'Low')").matches(e));
  assert(parseFilter("Version in ('1.0','2.0')").matches(e));

  foreach (bad; ["Name eq", "Name eq 'x", "foo(Name)", "Name eq 'a' )"]) {
    bool failed;
    try
      parseFilter(bad);
    catch (ODataException ex)
      failed = ex.status == 400;
    assert(failed, bad);
  }

  auto spec = parseQueryOptions(["$top": "5", "$skip": "10", "$orderby": "Name desc,ID", "$select": "ID,Name,DependsOn/Name", "$count": "true"]);
  assert(spec.top == 5 && spec.skip == 10 && spec.count);
  assert(spec.orderBy == [SortKey("Name", true), SortKey("ID", false)]);
  assert(spec.select == ["ID", "Name", "DependsOn"]);
}
