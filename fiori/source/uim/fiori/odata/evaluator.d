module uim.fiori.odata.evaluator;


import uim.fiori;

@safe:


/// Wendet $filter, $skip, $top und $select auf ein JSON-Array an
Json applyQueryOptions(Json dataSet, const ref ODataQueryOptions options) {
    if (dataSet.type != Json.Type.array) return dataSet;

    Json[] items = dataSet.toArray;

    // 1. $filter
    if (options.filterRaw.length > 0) {
        items = items.filter!(item => matchesFilter(item, options.filterRaw)).array;
    }

    // 2. $skip
    items = options.skip < items.length
        ? items[options.skip .. $]
        : [];

    // 3. $top
    if (options.top != size_t.max && options.top < items.length) {
        items = items[0 .. options.top];
    }

    // 4. $select
    if (options.select.length > 0) {
        Json[] projected;
        foreach (item; items) {
            Json newObj = Json.emptyObject;
            foreach (prop; options.select) {
                if (prop in item) {
                    newObj[prop] = item[prop];
                }
            }
            projected ~= newObj;
        }
        items = projected;
    }

    return Json(items);
}
unittest {
    writeln("Testing applyQueryOptions...");

    Json dataSet = parseJsonString(`
    [
        { "Id": "1", "Name": "Alice", "Age": 30 },
        { "Id": "2", "Name": "Bob", "Age": 25 },
        { "Id": "3", "Name": "Charlie", "Age": 35 }
    ]`);

    ODataQueryOptions options;
    options.filterRaw = "Age gt 28";
    options.skip = 0;
    options.top = 2;
    options.select = ["Id", "Name"];

    Json result = applyQueryOptions(dataSet, options);
    assert(result.type == Json.Type.array);
    assert(result.get!(Json[]).length == 2);
    assert(result.get!(Json[])[0]["Name"].get!string == "Alice");
    assert(result.get!(Json[])[1]["Name"].get!string == "Charlie");
}

/// Einfacher Parser für einfache Vergleiche (z.B. "Price gt 100" oder "Name eq 'Laptop'")
private bool matchesFilter(Json item, string filterExpr) {
    string[] ops = [" eq ", " ne ", " gt ", " ge ", " lt ", " le "];
    foreach (op; ops) {
        auto idx = filterExpr.indexOf(op);
        if (idx > 0 && (idx + op.length) < filterExpr.length) {
            string field = filterExpr[0 .. idx].strip;
            string valStr = filterExpr[idx + op.length .. $].strip;

            if (field !in item) return false;
            
            return compareValues(item[field], op.strip, valStr);
        }
    }
    return true;
}
unittest {
    writeln("Testing matchesFilter...");

    Json item = parseJsonString(`{ "Price": 150, "Name": "Laptop" }`);
    assert(matchesFilter(item, "Price gt 100"));
    assert(!matchesFilter(item, "Price lt 100"));
    assert(matchesFilter(item, "Name eq 'Laptop'"));
    assert(!matchesFilter(item, "Name ne 'Laptop'"));
}

private bool compareValues(Json val, string op, string rawExpected) {
    if (rawExpected.length >= 2 && rawExpected[0] == '\'' && rawExpected[$ - 1] == '\'') {
        rawExpected = rawExpected[1 .. $ - 1];
    }

    switch (val.type) {
        case Json.Type.string:
            string actual = val.get!string;
            if (op == "eq") return actual == rawExpected;
            if (op == "ne") return actual != rawExpected;
            break;
        case Json.Type.int_:
        case Json.Type.float_:
            double actual = val.to!double;
            double expected = 0.0;
            try { expected = rawExpected.to!double; } catch (Exception e) { return false; }
            
            if (op == "eq") return actual == expected;
            if (op == "ne") return actual != expected;
            if (op == "gt") return actual > expected;
            if (op == "ge") return actual >= expected;
            if (op == "lt") return actual < expected;
            if (op == "le") return actual <= expected;
            break;
        default:
            break;
    }
    return false;
}
unittest {
    writeln("Testing compareValues...");

    Json item = parseJsonString(`{ "Price": 150, "Name": "Laptop" }`);
    assert(compareValues(item["Price"], "gt", "100"));
    assert(!compareValues(item["Price"], "lt", "100"));
    assert(compareValues(item["Name"], "eq", "'Laptop'"));
    assert(!compareValues(item["Name"], "ne", "'Laptop'"));
}