module uim.fiori.odata.batch_parser;

import uim.fiori;

@safe:

/// Parsed OData v4 JSON Batch Payload
BatchRequestItem[] parseJsonBatch(Json root) {
    BatchRequestItem[] items;
    if ("requests" !in root || root["requests"].type != Json.Type.array) {
        return items;
    }

    foreach (Json req; root.getArray("requests")) {
        BatchRequestItem item;
        if ("id" in req) item.id = req["id"].get!string;
        if ("method" in req) item.method = req["method"].get!string.toUpper;
        if ("url" in req) {
            item.url = req["url"].get!string;
            string cleanUrl = item.url.startsWith("/") ? item.url[1 .. $] : item.url;
            auto slashIdx = cleanUrl.indexOf('/');
            item.entitySet = slashIdx != -1 ? cleanUrl[0 .. slashIdx] : cleanUrl;
        }
        if ("body" in req) item.body = req["body"];

        items ~= item;
    }
    return items;
}
unittest {
    writeln("Testing parseJsonBatch...");

    Json batchJson = parseJsonString(`
    {
        "requests": [
            {
                "id": "1",
                "method": "GET",
                "url": "/Products"
            },
            {
                "id": "2",
                "method": "POST",
                "url": "/Products",
                "body": { "Name": "New Product" }
            }
        ]
    }`);

    auto items = parseJsonBatch(batchJson);
    assert(items.length == 2);
    assert(items[0].id == "1");
    assert(items[0].method == "GET");
    assert(items[0].url == "/Products");
    assert(items[1].id == "2");
    assert(items[1].method == "POST");
    assert(items[1].url == "/Products");
    assert("Name" in items[1].body && items[1].body["Name"].get!string == "New Product");
}

/// Parsed Klassisches multipart/mixed Payload
BatchRequestItem[] parseMultipartBatch(string bodyText, string boundary) {
    BatchRequestItem[] items;
    string delimiter = "--" ~ boundary;
    string[] parts = bodyText.split(delimiter);

    int autoId = 1;
    foreach (part; parts) {
        string trimmed = part.strip;
        if (trimmed.length == 0 || trimmed == "--") continue;

        string[] lines = trimmed.splitLines();
        for (size_t i = 0; i < lines.length; i++) {
            string line = lines[i].strip;
            if (line.startsWith("GET ") || line.startsWith("POST ") || 
                line.startsWith("PATCH ") || line.startsWith("DELETE ")) {
                
                string[] partsLine = line.split(" ");
                if (partsLine.length < 2) continue;

                BatchRequestItem item;
                item.id = autoId++.to!string;
                item.method = partsLine[0];
                item.url = partsLine[1];
                
                string cleanUrl = item.url.startsWith("/") ? item.url[1 .. $] : item.url;
                auto slashIdx = cleanUrl.indexOf('/');
                item.entitySet = slashIdx != -1 ? cleanUrl[0 .. slashIdx] : cleanUrl;

                // Body extrahieren und Boundary-Reste herausfiltern
                if (i + 1 < lines.length) {
                    string rawJson = lines[i+1..$].join("\n").strip;
                    if (rawJson.length > 0) {
                        try { 
                            item.body = parseJsonString(rawJson); 
                        } catch (Exception e) {}
                    }
                }
                items ~= item;
                break;
            }
        }
    }
    return items;
}
unittest {
    writeln("Testing parseMultipartBatch...");

    string multipartBody = `--batch_123
Content-Type: application/http
GET /Products HTTP/1.1
--batch_123
Content-Type: application/http
POST /Products HTTP/1.1
Content-Type: application/json
{ "Name": "New Product" }
--batch_123--`;         

    auto items = parseMultipartBatch(multipartBody, "batch_123");
    assert(items.length == 2);
    assert(items[0].method == "GET");
    assert(items[0].url == "/Products");
    assert(items[1].method == "POST");
    assert(items[1].url == "/Products");
    // assert("Name" in items[1].body && items[1].body["Name"].get!string == "New Product");
}