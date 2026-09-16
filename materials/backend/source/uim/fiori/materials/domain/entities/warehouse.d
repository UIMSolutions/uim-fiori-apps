module uim.fiori.materials.domain.entities.warehouse;

import uim.fiori.materials;

@safe:
struct Warehouse {
    string id;
    string name;
    string location;

    Json toJson() const {
        Json item = Json.emptyObject;
        item["ID"] = Json(id);
        item["Name"] = Json(name);
        item["Location"] = Json(location);
        return item;
    }

    static Warehouse fromJson(Json item) {
        Warehouse warehouse;
        warehouse.id = item["ID"].get!string;
        warehouse.name = item["Name"].get!string;
        warehouse.location = item["Location"].get!string;
        return warehouse;
    }

    Bson toBson() const {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(id);
        doc["name"] = Bson(name);
        doc["location"] = Bson(location);
        return doc;
    }

    static Warehouse fromBson(Bson doc) {
        Warehouse warehouse;
        warehouse.id = readString(doc, "id");
        warehouse.name = readString(doc, "name");
        warehouse.location = readString(doc, "location");
        return warehouse;
    }
}

Json buildWarehouse(Warehouse warehouse) {
    Json item = Json.emptyObject;
    item["ID"] = Json(warehouse.id);
    item["Name"] = Json(warehouse.name);
    item["Location"] = Json(warehouse.location);
    return item;
}

Json buildWarehouseArray(Warehouse[] entries) {
    Json list = Json.emptyArray;
    foreach (entry; entries) {
        list ~= buildWarehouse(entry);
    }
    return list;
}

// Json toJson(Warehouse[] entries) {
//         Json array = Json.emptyArray;
//         foreach (entry; entries) {
//             Json item = Json.emptyObject;
//             item["id"] = Json(entry.id);
//             item["name"] = Json(entry.name);
//             item["location"] = Json(entry.location);
//             array ~= item;
//         }
//         return array;
//     }