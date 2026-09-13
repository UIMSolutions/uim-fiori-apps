module uim.fiori.material.domain.entities.material;
import uim.fiori.material;
@safe:
struct Material {
    string id;
    string name;
    string description;
    double targetStock;
    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("name", name)
            .set("description", description)
            .set("targetStock", targetStock);
    }
    static Material fromJson(Json json) {
        auto material = Material();
        material.id = json.getString("id");
        material.name = json.getString("name");
        material.description = json.getString("description");
        material.targetStock = json.getDouble("targetStock");
        return material;
    }
}
