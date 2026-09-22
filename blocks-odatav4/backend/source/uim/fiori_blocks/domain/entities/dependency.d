module uim.fiori_blocks.domain.entities.dependency;

import uim.fiori_blocks;

@safe:

struct Dependency {
    string ID;           // z.B. "AB-02"
    string Name;         // z.B. "Integration Gateway"
    string Type;         // z.B. "Uses API", "Requires DB", "Event Trigger"
    string Criticality;  // z.B. "High", "Medium", "Low"

    Json toJson() const {
        return Json.emptyObject
            .set("ID", ID)
            .set("Name", Name)
            .set("Type", Type)
            .set("Criticality", Criticality);
    }
}
