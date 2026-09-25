module uim.fiori_blocks.domain.entities.interface_;

import uim.fiori_blocks;

@safe:

struct InterfaceBlock {
    string ID;
    string Name;
    string Type; // Architecture, Solution, Interface
    string Description;
    string Status;

    bool isNull() const {
        return ID.length == 0;
    }

    Json toJson() const {
        return Json.emptyObject
            .set("ID", ID)
            .set("Name", Name)
            .set("Type", Type)
            .set("Description", Description)
            .set("Status", Status);
    }

    static InterfaceBlock fromJson(Json json) {
        auto block = InterfaceBlock();

        block.ID = json.getString("");
        block.Name = json.getString("");
        block.Type = json.getString(""); // Architecture, Solution, Interfae
        block.Description = json.getString("");
        block.Status = json.getString("");

        return block; 
    }
}
