module odata4;

import std.algorithm : canFind, min, sort, SwapStrategy;
import std.array : array, split;
import std.conv : to, ConvException;
import std.regex : ctRegex, matchFirst;
import std.string : indexOf, strip, toLower;
import std.uni : isAlpha, isAlphaNum, isWhite;
import vibe.data.json;

import data;

class ODataException : Exception
{
	int status;
	this(int status, string msg) { super(msg); this.status = status; }
}

/// Handles "Set", "Set(key)" with $filter, $orderby, $top, $skip, $count and $select.
Json handleRequest(string path, string[string] query)
{
	string setName = path;
	string key;
	auto p = path.indexOf('(');
	if (p >= 0 && path[$ - 1] == ')')
	{
		setName = path[0 .. p];
		key = path[p + 1 .. $ - 1];
	}

	Json[] rows;
	switch (setName)
	{
	case "Products": rows = productRows; break;
	case "Orders": rows = orderRows; break;
	default: throw new ODataException(404, "Resource not found: " ~ setName);
	}
	auto ctx = "$metadata#" ~ setName;
	auto o = Json.emptyObject;

	if (key.length)
	{
		foreach (r; rows)
			if (r["ID"].to!string == key)
			{
				auto e = select(r, query);
				e["@odata.context"] = ctx ~ "/$entity";
				return e;
			}
		throw new ODataException(404, "Entity not found");
	}

	auto items = rows.dup;
	if (auto f = "$filter" in query)
	{
		auto parser = FilterParser(*f);
		Json[] kept;
		foreach (r; items)
			if (parser.eval(r))
				kept ~= r;
		items = kept;
	}
	auto total = items.length;

	if (auto ob = "$orderby" in query)
		foreach_reverse (part; (*ob).split(","))
		{
			auto s = part.strip.split(" ");
			bool desc = s.length > 1 && s[1].toLower == "desc";
			auto prop = s[0];
			items.sort!((a, b) => desc ? compareJson(b[prop], a[prop]) < 0
				: compareJson(a[prop], b[prop]) < 0, SwapStrategy.stable);
		}
	if (auto s = "$skip" in query)
		items = items[min(parseCount(*s), $) .. $];
	if (auto t = "$top" in query)
		items = items[0 .. min(parseCount(*t), $)];

	o["@odata.context"] = ctx;
	if (auto c = "$count" in query)
		if (*c == "true")
			o["@odata.count"] = total;
	auto arr = Json.emptyArray;
	foreach (r; items)
		arr ~= select(r, query);
	o["value"] = arr;
	return o;
}

private:

size_t parseCount(string s)
{
	try return s.to!size_t;
	catch (ConvException) throw new ODataException(400, "Invalid number: " ~ s);
}

Json select(Json row, string[string] query)
{
	auto sel = "$select" in query;
	if (sel is null)
		return row.clone;
	auto o = Json.emptyObject;
	foreach (n; (*sel).split(","))
		if (n.strip in row)
			o[n.strip] = row[n.strip];
	return o;
}

int compareJson(Json a, Json b)
{
	if (a.type == Json.Type.string || b.type == Json.Type.string)
	{
		auto x = a.to!string, y = b.to!string;
		return x < y ? -1 : x > y ? 1 : 0;
	}
	auto x = a.to!double, y = b.to!double;
	return x < y ? -1 : x > y ? 1 : 0;
}

/// $filter subset: and / or / not, parentheses, eq ne lt le gt ge, contains/startswith/endswith.
struct FilterParser
{
	string src;
	size_t pos;
	Json item;

	this(string s) { src = s; }

	bool eval(Json i)
	{
		item = i;
		pos = 0;
		auto r = parseOr();
		skipWs();
		if (pos != src.length)
			throw new ODataException(400, "Invalid $filter near: " ~ src[pos .. $]);
		return r;
	}

	void skipWs() { while (pos < src.length && src[pos].isWhite) pos++; }

	bool word(string w)
	{
		skipWs();
		auto end = pos + w.length;
		if (end <= src.length && src[pos .. end].toLower == w && (end == src.length || !src[end].isAlphaNum))
		{
			pos = end;
			return true;
		}
		return false;
	}

	bool ch(char c)
	{
		skipWs();
		if (pos < src.length && src[pos] == c) { pos++; return true; }
		return false;
	}

	bool parseOr()
	{
		auto r = parseAnd();
		while (word("or")) { auto o = parseAnd(); r = r || o; }
		return r;
	}

	bool parseAnd()
	{
		auto r = parseUnary();
		while (word("and")) { auto o = parseUnary(); r = r && o; }
		return r;
	}

	bool parseUnary()
	{
		if (word("not")) return !parseUnary();
		if (ch('('))
		{
			auto r = parseOr();
			if (!ch(')')) throw new ODataException(400, "Missing ')' in $filter");
			return r;
		}
		foreach (fn; ["contains", "startswith", "endswith"])
			if (word(fn))
			{
				ch('(');
				auto a = parseValue().to!string.toLower;
				ch(',');
				auto b = parseValue().to!string.toLower;
				ch(')');
				final switch (fn)
				{
				case "contains": return a.canFind(b);
				case "startswith": return a.length >= b.length && a[0 .. b.length] == b;
				case "endswith": return a.length >= b.length && a[$ - b.length .. $] == b;
				}
			}
		auto left = parseValue();
		foreach (op; ["eq", "ne", "lt", "le", "gt", "ge"])
			if (word(op))
			{
				auto c = compareJson(left, parseValue());
				switch (op)
				{
				case "eq": return c == 0;
				case "ne": return c != 0;
				case "lt": return c < 0;
				case "le": return c <= 0;
				case "gt": return c > 0;
				default: return c >= 0;
				}
			}
		throw new ODataException(400, "Invalid $filter expression");
	}

	Json parseValue()
	{
		skipWs();
		if (pos >= src.length) throw new ODataException(400, "Unexpected end of $filter");
		if (src[pos] == '\'')
		{
			string s;
			pos++;
			while (pos < src.length)
			{
				if (src[pos] == '\'')
				{
					if (pos + 1 < src.length && src[pos + 1] == '\'') { s ~= '\''; pos += 2; continue; }
					pos++;
					return Json(s);
				}
				s ~= src[pos++];
			}
			throw new ODataException(400, "Unterminated string in $filter");
		}
		auto start = pos;
		if (src[pos].isAlpha)
		{
			while (pos < src.length && (src[pos].isAlphaNum || src[pos] == '_')) pos++;
			auto w = src[start .. pos];
			return w in item ? item[w] : Json(null);
		}
		while (pos < src.length && (src[pos].isAlphaNum || src[pos] == '.' || src[pos] == '-')) pos++;
		try return Json(src[start .. pos].to!double);
		catch (ConvException) throw new ODataException(400, "Invalid literal: " ~ src[start .. pos]);
	}
}
