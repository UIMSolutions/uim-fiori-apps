module uim.fiori_blocks.domain.entities.solution;

import uim.fiori_blocks;

@safe:

struct SolutionBlock {
    string ID;
    string Name;
    string Title;
    string Description;
    string ValidFrom;
    string ValidUntil;
    string Version;
    string Date;
    string AdditionalInfo;
    string Responsibles;
    Dependency[] DependsOnSolutionBlocks;

    bool isNull() const {
        return ID.length == 0;
    }

    Json toJson() const {
        return Json.emptyObject
            .set("ID", ID)
            .set("Name", Name)
            .set("Title", Title)
            .set("Description", Description)
            .set("ValidFrom", ValidFrom)
            .set("ValidUntil", ValidUntil)
            .set("Version", Version)
            .set("Date", Date)
            .set("AdditionalInfo", AdditionalInfo)
            .set("Responsibles", Responsibles)
            .set("DependsOnSolutionBlocks", DependsOnSolutionBlocks.map!(d => d.toJson).array.toJson);
    }

    static SolutionBlock fromJson(Json json) {
        auto block = SolutionBlock();
        block.ID = json.getString("ID");
        block.Name = json.getString("Name");
        block.Title = json.getString("Title");
        block.Description = json.getString("Description");
        block.ValidFrom = json.getString("ValidFrom");
        block.ValidUntil = json.getString("ValidUntil");
        block.Version = json.getString("Version");
        block.Date = json.getString("Date");
        block.AdditionalInfo = json.getString("AdditionalInfo");
        block.Responsibles = json.getString("Responsibles");

        block.DependsOnSolutionBlocks = json.getArray("DependsOnSolutionBlocks").map!(d => Dependency.fromJson(d)).array;

        return block;
    }

}
