module uim.fiori_blocks.domain.entities.dependency;

import uim.fiori_blocks;

@safe:

struct Dependency {
    string ID;           // z.B. "AB-02"
    string Name;         // z.B. "Integration Gateway"
    string Type;         // z.B. "Uses API", "Requires DB", "Event Trigger"
    string Criticality;  // z.B. "High", "Medium", "Low"

    bool isNull() const {
        return ID.length == 0;
    }

    Json toJson() const {
        return Json.emptyObject
            .set("ID", ID)
            .set("Name", Name)
            .set("Type", Type)
            .set("Criticality", Criticality);
    }

    static Dependency fromJson(Json json) {
        auto dependency = Dependency();
        dependency.ID = json.getString("ID", "");
        dependency.Name = json.getString("Name", "");
        dependency.Type = json.getString("Type", "");
        dependency.Criticality = json.getString("Criticality", "");

        return dependency;
    }

}
