module uim.fiori.odata.controller;

import uim.fiori;

@safe:

interface ODataController {
/// GET /EntitySet mit optionaler $expand Option
    Json getEntitySet(string entitySetName, string expand = "");
    
    /// GET /EntitySet('1001') (Einzel-Entität abfragen)
    Json getEntity(string entitySetName, string id, string expand = "");

    /// POST /EntitySet (Entität erstellen)
    Json createEntity(string entitySetName, Json payload);

    /// PATCH /EntitySet('1001') (Entität teilweise aktualisieren)
    Json updateEntity(string entitySetName, string id, Json payload);

    /// DELETE /EntitySet('1001') (Entität löschen)
    bool deleteEntity(string entitySetName, string id);

    Json getEntitiesJson();
}