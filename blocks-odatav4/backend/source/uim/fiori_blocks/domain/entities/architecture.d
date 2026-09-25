module uim.fiori_blocks.domain.entities.architecture;

import uim.fiori_blocks;

@safe:

struct ArchitectureBlock {
    string ID;
    string Name;
    string Responsible;
    string Version;
    string Modul;
    string Service;
    string Product;
    string Date;
    string Description;
    string AdditionalInfo;

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
            .set("Modul", Modul)
            .set("Service", Service)
            .set("Product", Product)
            .set("Date", Date)
            .set("Description", Description)
            .set("AdditionalInfo", AdditionalInfo)
            .set("DependsOn", DependsOn.map!(d => d.toJson).array.toJson);
    }

    static ArchitectureBlock fromJson(Json json) {
        auto block = ArchitectureBlock();
        block.ID = json.getString("ID");
        block.Name = json.getString("Name");
        block.Responsible = json.getString("Responsible");
        block.Version = json.getString("Version");
        block.Modul = json.getString("Modul");
        block.Service = json.getString("Service");
        block.Product = json.getString("Product");
        block.Date = json.getString("Date");
        block.Description = json.getString("Description");
        block.AdditionalInfo = json.getString("AdditionalInfo");

        block.DependsOn = json.getArray("DependsOn").map!(d => Dependency.fromJson(d)).array;

        return block;
    }

}