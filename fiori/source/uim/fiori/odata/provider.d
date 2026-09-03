module uim.fiori.odata.provider;

import uim.fiori;

@safe:

interface IODataProvider {
    Json getEntitySet(string entitySetName, const ref ODataQueryOptions options);
    Json getEntity(string entitySetName, string key, const ref ODataQueryOptions options);
    Json createEntity(string entitySetName, Json payload);
}
/// Generiert das Service Document (GET /api/v4/)
Json generateServiceDocument(string[] entitySetNames) {
    Json value = Json.emptyArray;
    foreach (name; entitySetNames) {
        value ~= Json.emptyObject
            .set("name", name)
            .set("kind", "EntitySet")
            .set("url", name);
    }

    return Json.emptyObject
        .set("@odata.context", "$metadata")
        .set("value", value);
}
///
unittest {
    writeln("Testing generateServiceDocument...");

    string[] entitySetNames = ["Persons", "Orders"];
    Json serviceDoc = generateServiceDocument(entitySetNames);

    assert(serviceDoc["@odata.context"].get!string == "$metadata");
    assert(serviceDoc["value"].isArray);
    assert(serviceDoc["value"].length == 2);
    assert(serviceDoc["value"][0]["name"].get!string == "Persons");
    assert(serviceDoc["value"][1]["name"].get!string == "Orders");  
}
