module uim.fiori.materials.domain.entities.material;

import uim.fiori.materials;
import vibe.data.serialization : name;

@safe:
struct Material {
    @name("ID") string id;
    @name("Name") string materialName;
    @name("Description") string description;
    @name("TargetStock") double targetStock;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("name", materialName)
            .set("description", description)
            .set("targetStock", targetStock);
    }

    static Material fromJson(Json json) {
        auto material = Material();
        material.id = json.getString("id");
        material.materialName = json.getString("name");
        material.description = json.getString("description");
        material.targetStock = json.getDouble("targetStock");
        return material;
    }

    Bson toBson() const {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(id);
        doc["name"] = Bson(materialName);
        doc["description"] = Bson(description);
        doc["targetStock"] = Bson(targetStock);
        return doc;
    }

    static Material fromBson(Bson doc) {
        Material material;
        material.id = readString(doc, "id");
        material.materialName = readString(doc, "name");
        material.description = readString(doc, "description");
        material.targetStock = readDouble(doc, "targetStock");
        return material;
    }
}

Json buildMaterial(
    Material material,
    bool includeAssignments,
    bool includeWarehouse,
    WarehouseAssignment[] assignments,
    Warehouse[] warehouses,
    string[] select = null
) {
    Json item = Json.emptyObject;
    if (select.length == 0 || select.canFind("ID")) {
        item["ID"] = Json(material.id);
    }
    if (select.length == 0 || select.canFind("Name")) {
        item["Name"] = Json(material.materialName);
    }
    if (select.length == 0 || select.canFind("Description")) {
        item["Description"] = Json(material.description);
    }
    if (select.length == 0 || select.canFind("TargetStock")) {
        item["TargetStock"] = Json(material.targetStock);
    }
    if (includeAssignments) {
        Json expandedAssignments = Json.emptyArray;
        foreach (assignment; assignments) {
            if (assignment.materialId == material.id) {
                expandedAssignments ~= buildAssignment(
                    assignment,
                    includeWarehouse,
                    warehouses
                );
            }
        }
        item["Assignments"] = expandedAssignments;
    }
    return item;
}

Json buildMaterialArray(
    Material[] entries,
    bool includeAssignments,
    bool includeWarehouse,
    WarehouseAssignment[] assignments,
    Warehouse[] warehouses,
    string[] select = null
) {
    Json list = Json.emptyArray;
    foreach (entry; entries) {
        list ~= buildMaterial(
            entry,
            includeAssignments,
            includeWarehouse,
            assignments,
            warehouses,
            select
        );
    }
    return list;
}

Material extractMaterialFromRequest(string requestBody) {
    foreach (line; requestBody.splitLines()) {
        writeln("Processing line: ", line);
        if (!line.strip().canFind("{"))
            continue;
        auto json = parseJsonString(line);
        auto material = Material();
        material.id = json.getString("ID");
        material.materialName = json.getString("Name");
        material.description = json.getString("Description");
        material.targetStock = json.getDouble("TargetStock");
        return material;
    }
    return Material.init;
}

// Json toJson(Material[] entries) {
//     Json array = Json.emptyArray;
//     foreach (entry; entries) {
//         Json item = Json.emptyObject;
//         item["id"] = Json(entry.id);
//         item["name"] = Json(entry.name);
//         item["description"] = Json(entry.description);
//         item["targetStock"] = Json(entry.targetStock);
//         array ~= item;
//     }
//     return array;
// }
