module uim.fiori.odata.controller;
import uim.fiori;

@safe:
interface ODataController {
    /// GET /EntitySet with optional $expand option
    Json getEntitySet(string entitySetName, string expand = "");

    /// GET /EntitySet('1001') (Retrieve a single entity)
    Json getEntity(string entitySetName, string id, string expand = "");
    
    /// POST /EntitySet (Create an entity)
    Json createEntity(string entitySetName, Json payload);
    
    /// PATCH /EntitySet('1001') (Partially update an entity)
    Json updateEntity(string entitySetName, string id, Json payload);
    
    /// DELETE /EntitySet('1001') (Delete an entity)
    bool deleteEntity(string entitySetName, string id);
    
    // Handle batch request and generate appropriate response
    BatchResponseItem response(BatchRequestItem item);
}
