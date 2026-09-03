module uim.fiori.odata.batch;

import uim.fiori;

@safe:


/// Repräsentiert eine einzelne Operation innerhalb eines Batch-Requests
struct BatchRequestItem {
    string id; // Eindeutige ID der Operation
    string method; // "GET", "POST", "PATCH", "DELETE"
    string url;    // Relativer Pfad
    string entitySet; // Optional: EntitySet, falls bekannt
    Json body; // Optional: Nutzdaten der Anfrage
    string[string] headers; // 
}
unittest {
    writeln("Testing BatchRequestItem...");

    BatchRequestItem item;
    item.id = "1";
    item.method = "POST";
    item.url = "/Products";
    item.entitySet = "Products";
    item.body = Json.emptyObject
        .set("Name", "New Product");
    item.headers["Content-Type"] = "application/json";

    assert(item.id == "1");
    assert(item.method == "POST");
    assert(item.url == "/Products");
    assert(item.entitySet == "Products");
    assert(item.body.getString("Name") == "New Product");
    assert(item.headers["Content-Type"] == "application/json");
}

/// Repräsentiert die Antwort auf eine einzelne Batch-Operation
struct BatchResponseItem {
    string id;
    int status = 200;
    Json body;
    string[string] headers;

    Json toJson() const {
        Json hdrs = Json.emptyObject;
        foreach (k, v; headers) {
            hdrs[k] = v;
        }

        return Json.emptyObject
            .set("id", id)
            .set("status", status)
            .set("headers", hdrs)
            .set("body", body);
    }
}
unittest {
    writeln("Testing BatchResponseItem.toJson...");

    BatchResponseItem resp;
    resp.id = "1";
    resp.status = 201;
    resp.body = Json.emptyObject;
    resp.body["Id"] = "1001";
    resp.body["Name"] = "New Product";
    resp.headers["Content-Type"] = "application/json";

    Json jsonResp = resp.toJson();
    assert(jsonResp["id"].get!string == "1");
    assert(jsonResp["status"].get!int == 201);
    assert("Id" in jsonResp["body"] && jsonResp["body"]["Id"].get!string == "1001");
    assert(jsonResp["headers"]["Content-Type"].get!string == "application/json");
}