module uim.fiori_blocks.domain.entities.interface_;

import uim.fiori_blocks;

@safe:

struct InterfaceBlock {
    string ID;
    string Name;
    string Type; // Architecture, Solution, Interface
    string Description;
    string Status;

    Json toJson() const {
        return Json.emptyObject
            .set("ID", ID)
            .set("Name", Name)
            .set("Type", Type)
            .set("Description", Description)
            .set("Status", Status);
    }
}
