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
}
