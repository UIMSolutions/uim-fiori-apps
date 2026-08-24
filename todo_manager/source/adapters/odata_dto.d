module adapters.odata_dto;

import domain;
import vibe.data.json; // Wichtig für @name
@safe:
// Single Entity Payload
struct ODataEntity {
    string id;
    string title;
    string description;
    bool isCompleted;
    string createdAt;

    // Ordnet das JSON-Property "@odata.context" dem D-Feld odataContext zu
    @name("@odata.context") 
    string odataContext;
}

// Collection Payload
struct ODataCollection {
    @name("@odata.context") 
    string odataContext;
    
    ODataEntity[] value;
}

// Helper-Funktion
ODataEntity toOData(TodoTask TodoTask, string metaContext = "") {
    return ODataEntity(
        TodoTask.id,
        TodoTask.title,
        TodoTask.description,
        TodoTask.isCompleted,
        TodoTask.createdAt.toISOString(),
        metaContext // Wichtig: Wird dem odataContext Feld zugewiesen
    );
}