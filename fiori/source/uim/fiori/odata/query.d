module uim.fiori.odata.query;

import uim.fiori;

@safe:


/// Repräsentiert die geparsten OData v4 System Query Option Werte
struct ODataQueryOptions {
    size_t top = size_t.max;
    size_t skip = 0;
    string[] select;
    string filterRaw;
}

/// Extrahiert OData v4 Parameter aus einem Vibe.d Request
ODataQueryOptions parseQueryOptions(HTTPServerRequest req) {
    ODataQueryOptions options;

    if (auto pTop = "$top" in req.query) {
        try { options.top = (*pTop).to!size_t; } catch (ConvException e) {}
    }

    if (auto pSkip = "$skip" in req.query) {
        try { options.skip = (*pSkip).to!size_t; } catch (ConvException e) {}
    }

    if (auto pSelect = "$select" in req.query) {
        options.select = (*pSelect).splitter(',').map!(s => s.strip).array;
    }

    if (auto pFilter = "$filter" in req.query) {
        options.filterRaw = *pFilter;
    }

    return options;
}
unittest {
    // writeln("Testing parseQueryOptions...");
    // 
    // HTTPServerRequest req;
    // req.query["$top"] = "10";
    // req.query["$skip"] = "5";
    // req.query["$select"] = "Name, Age";
    // req.query["$filter"] = "Age gt 30";
// 
    // ODataQueryOptions options = parseQueryOptions(req);
    // assert(options.top == 10);
    // assert(options.skip == 5);
    // assert(options.select.length == 2);
    // assert(options.select[0] == "Name");
    // assert(options.select[1] == "Age");
    // assert(options.filterRaw == "Age gt 30");
}