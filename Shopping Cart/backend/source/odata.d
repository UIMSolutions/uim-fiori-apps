module odata;

import std.algorithm : SwapStrategy, canFind, filter, map, min, sort;
import std.array : array, split;
import std.conv : to, ConvException;
import std.file : readText;
import std.path : buildPath;
import std.string : indexOf, strip, toLower;
import std.uni : isAlpha, isAlphaNum, isWhite;
import vibe.data.json;

class ODataException : Exception
{
	int status;
	this(int status, string msg) { super(msg); this.status = status; }
}

struct EntitySetInfo
{
	string typeName;
	string file;
	string[] keys;
}

/// Entity set definitions of the EPM_DEVELOPER_SCENARIO_SRV service.
immutable EntitySetInfo[string] entitySets;

shared static this()
{
	entitySets = [
		"Products": EntitySetInfo("Product", "Product.json", ["ProductId"]),
		"ProductCategories": EntitySetInfo("ProductCategory", "ProductCategory.json", ["Category"]),
		"FeaturedProducts": EntitySetInfo("FeaturedProduct", "FeaturedProduct.json", ["ProductId", "Type"]),
	];
}


class DataStore
{
	Json[][string] rows;

	this(string dir)
	{
		foreach (name, info; entitySets)
		{
			Json[] list;
			foreach (j; parseJsonString(readText(buildPath(dir, info.file))))
				list ~= j;
			rows[name] = list;
		}
	}
}

/// Resolves /Set, /Set('key'), /Set('key')/NavProp and returns the OData V2 JSON payload.
Json resolve(DataStore store, string[] segments, string[string] query)
{
	if (segments.length == 0)
		throw new ODataException(404, "Missing resource");

	string setName;
	string key;
	bool hasKey = parseSegment(segments[0], setName, key);
	if (setName !in entitySets)
		throw new ODataException(404, "Resource not found: " ~ setName);

	Json[] items = store.rows[setName].dup;
	bool single = false;
	if (hasKey)
	{
		items = items.filter!(i => matchesKey(setName, i, key)).array;
		if (items.length == 0)
			throw new ODataException(404, "Entity not found");
		single = true;
	}

	if (segments.length > 1)
	{
		bool collection;
		items = navigate(store, setName, items, segments[1], collection);
		single = !collection;
		setName = collection || items.length == 0 ? navTarget(setName, segments[1]) : navTarget(setName, segments[1]);
		if (single && items.length == 0)
			throw new ODataException(404, "Entity not found");
	}

	auto expand = "$expand" in query ? (*("$expand" in query)).split(",").map!(s => s.strip).array : null;

	if (single)
		return Json(["d": expandEntity(store, setName, items[0], expand)]);

	if (auto f = "$filter" in query)
	{
		auto expr = Parser(*f);
		items = items.filter!(i => expr.eval(i)).array;
	}
	auto total = items.length;

	if (auto o = "$orderby" in query)
	{
		foreach_reverse (part; (*o).split(","))
		{
			auto p = part.strip.split(" ");
			bool desc = p.length > 1 && p[1].toLower == "desc";
			auto prop = p[0];
			items.sort!((a, b) => desc ? compareJson(b[prop], a[prop]) < 0 : compareJson(a[prop], b[prop]) < 0,
				SwapStrategy.stable);
		}
	}
	if (auto s = "$skip" in query)
		items = items[min((*s).to!size_t, $) .. $];
	if (auto t = "$top" in query)
		items = items[0 .. min((*t).to!size_t, $)];

	Json[] outRows;
	foreach (i; items)
		outRows ~= expandEntity(store, setName, i, expand);

	auto d = Json.emptyObject;
	d["results"] = Json(outRows);
	if (auto ic = "$inlinecount" in query)
		if (*ic == "allpages")
			d["__count"] = Json(total.to!string);
	return Json(["d": d]);
}

private:

import std.algorithm : joiner;
import std.range : isInputRange;

bool parseSegment(string seg, out string name, out string key)
{
	auto p = seg.indexOf('(');
	if (p < 0)
	{
		name = seg;
		return false;
	}
	name = seg[0 .. p];
	auto inner = seg[p + 1 .. $ - 1];
	key = inner;
	return true;
}

/// Key text is either 'value' or Name='value',Name2='value2'.
bool matchesKey(string setName, Json item, string key)
{
	auto keys = entitySets[setName].keys;
	string[string] kv;
	if (key.indexOf('=') < 0)
		kv[keys[0]] = unquote(key);
	else
		foreach (part; key.split(","))
		{
			auto eq = part.indexOf('=');
			kv[part[0 .. eq].strip] = unquote(part[eq + 1 .. $]);
		}
	foreach (k, v; kv)
		if (item[k].to!string != v)
			return false;
	return true;
}

string unquote(string s)
{
	s = s.strip;
	if (s.length >= 2 && s[0] == '\'' && s[$ - 1] == '\'')
		return s[1 .. $ - 1].replace2("''", "'");
	return s;
}

string replace2(string s, string from, string to)
{
	import std.array : replace;
	return s.replace(from, to);
}

string navTarget(string setName, string nav)
{
	switch (setName ~ "/" ~ nav)
	{
	case "Products/ProductCategory": return "ProductCategories";
	case "ProductCategories/Products": return "Products";
	case "FeaturedProducts/Product": return "Products";
	default: throw new ODataException(404, "Unknown navigation property: " ~ nav);
	}
}

Json[] navigate(DataStore store, string setName, Json[] items, string nav, out bool collection)
{
	auto target = navTarget(setName, nav);
	collection = nav == "Products";
	Json[] result;
	foreach (item; items)
		foreach (t; store.rows[target])
		{
			bool match = nav == "Products" ? t["Category"] == item["Category"] : (nav == "ProductCategory"
				? t["Category"] == item["Category"] : t["ProductId"] == item["ProductId"]);
			if (match)
				result ~= t;
		}
	return result;
}

Json expandEntity(DataStore store, string setName, Json item, string[] expand)
{
	if (expand.length == 0)
		return item;
	auto o = item.clone;
	foreach (nav; expand)
	{
		bool collection;
		auto related = navigate(store, setName, [item], nav, collection);
		if (collection)
		{
			auto r = Json.emptyObject;
			r["results"] = Json(related);
			o[nav] = r;
		}
		else
			o[nav] = related.length ? related[0] : Json(null);
	}
	return o;
}

double asNumber(Json j, out bool ok)
{
	ok = true;
	if (j.type == Json.Type.int_ || j.type == Json.Type.float_)
		return j.get!double;
	if (j.type == Json.Type.string)
		try return j.get!string.to!double; catch (ConvException) {}
	ok = false;
	return 0;
}

int compareJson(Json a, Json b)
{
	bool oa, ob;
	auto na = asNumber(a, oa);
	auto nb = asNumber(b, ob);
	if (oa && ob)
		return na < nb ? -1 : na > nb ? 1 : 0;
	auto sa = a.to!string, sb = b.to!string;
	return sa < sb ? -1 : sa > sb ? 1 : 0;
}

/// Recursive-descent evaluator for the OData V2 $filter subset used by UI5:
/// and/or/not, parentheses, eq ne lt le gt ge, substringof/startswith/endswith.
struct Parser
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

	bool acceptWord(string w)
	{
		skipWs();
		auto end = pos + w.length;
		if (end <= src.length && src[pos .. end].toLower == w
			&& (end == src.length || !src[end].isAlphaNum))
		{
			pos = end;
			return true;
		}
		return false;
	}

	bool acceptChar(char c)
	{
		skipWs();
		if (pos < src.length && src[pos] == c) { pos++; return true; }
		return false;
	}

	bool parseOr()
	{
		auto r = parseAnd();
		while (acceptWord("or")) { auto o = parseAnd(); r = r || o; }
		return r;
	}

	bool parseAnd()
	{
		auto r = parseUnary();
		while (acceptWord("and")) { auto o = parseUnary(); r = r && o; }
		return r;
	}

	bool parseUnary()
	{
		if (acceptWord("not")) return !parseUnary();
		if (acceptChar('('))
		{
			auto r = parseOr();
			if (!acceptChar(')')) throw new ODataException(400, "Missing ')' in $filter");
			return r;
		}
		foreach (fn; ["substringof", "startswith", "endswith"])
			if (acceptWord(fn))
			{
				acceptChar('(');
				auto a = parseValue();
				acceptChar(',');
				auto b = parseValue();
				acceptChar(')');
				auto sa = a.to!string.toLower, sb = b.to!string.toLower;
				final switch (fn)
				{
				case "substringof": return sa.length == 0 ? true : sb.canFind(sa);
				case "startswith": return sa.length >= sb.length && sa[0 .. sb.length] == sb;
				case "endswith": return sa.length >= sb.length && sa[$ - sb.length .. $] == sb;
				}
			}
		auto left = parseValue();
		foreach (op; ["eq", "ne", "lt", "le", "gt", "ge"])
			if (acceptWord(op))
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
		if (src[pos].isAlpha || src[pos] == '_')
		{
			while (pos < src.length && (src[pos].isAlphaNum || src[pos] == '_' || src[pos] == '/')) pos++;
			auto word = src[start .. pos];
			if (word == "true") return Json(true);
			if (word == "false") return Json(false);
			if (word == "null") return Json(null);
			return word in item ? item[word] : Json(null);
		}
		while (pos < src.length && (src[pos].isAlphaNum || src[pos] == '.' || src[pos] == '-')) pos++;
		auto num = src[start .. pos];
		// Strip OData numeric suffixes (m, M, d, D, L, f).
		while (num.length && "mMdDLf".canFind(num[$ - 1])) num = num[0 .. $ - 1];
		try return Json(num.to!double);
		catch (ConvException) throw new ODataException(400, "Invalid literal: " ~ num);
	}
}
