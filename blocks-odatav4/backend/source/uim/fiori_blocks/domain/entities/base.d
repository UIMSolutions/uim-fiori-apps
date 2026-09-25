module uim.fiori_blocks.domain.entities.base;

import uim.fiori_blocks;

@safe:

struct BaseBlock {
    string ID;
    string Name;
    string Responsible;
    string Version;
    string Date;
    string Description;
    string[] AdditionalInformation;

    Dependency[] DependsOn;

    bool isNull() const {
        return ID.length == 0;
    }

    Json toJson() const {
        return Json.emptyObject
        .set("ID", ID)
        .set("Name", Name)
        .set("Responsible", Responsible)
        .set("Version", Version)
        .set("Date", Date)
        .set("Description", Description)
        .set("AdditionalInformation", AdditionalInformation.map!(info => Json(info)).array.toJson)
        .set("DependsOn", DependsOn.map!(d => d.toJson).array.toJson);
    }
}