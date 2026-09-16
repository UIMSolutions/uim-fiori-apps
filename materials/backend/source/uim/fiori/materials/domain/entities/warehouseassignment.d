module uim.fiori.materials.domain.entities.warehouseassignment;

import uim.fiori.materials;

@safe:
struct WarehouseAssignment {
    string id; /// The ID of the warehouse assignment.
    string materialId; /// The ID of the material associated with this warehouse assignment.
    string warehouseId; /// The ID of the warehouse associated with this warehouse assignment.

    Json toJson() const {
        Json item = Json.emptyObject;
        item["ID"] = Json(id);
        item["MaterialID"] = Json(materialId);
        item["WarehouseID"] = Json(warehouseId);
        return item;
    }

    static WarehouseAssignment fromJson(Json item) {
        WarehouseAssignment assignment;
        assignment.id = item["ID"].get!string;
        assignment.materialId = item["MaterialID"].get!string;
        assignment.warehouseId = item["WarehouseID"].get!string;
        return assignment;
    }

    Bson toBson() const {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(id);
        doc["materialId"] = Bson(materialId);
        doc["warehouseId"] = Bson(warehouseId);
        return doc;
    }

    static WarehouseAssignment fromBson(Bson doc) {
        WarehouseAssignment assignment;
        assignment.id = readString(doc, "id");
        assignment.materialId = readString(doc, "materialId");
        assignment.warehouseId = readString(doc, "warehouseId");
        return assignment;
    }
}

Json buildAssignment(
    WarehouseAssignment assignment,
    bool includeWarehouse,
    Warehouse[] warehouses
) {
    Json item = Json.emptyObject;
    item["ID"] = Json(assignment.id);
    item["MaterialID"] = Json(assignment.materialId);
    item["WarehouseID"] = Json(assignment.warehouseId);
    if (includeWarehouse) {
        foreach (warehouse; warehouses) {
            if (warehouse.id == assignment.warehouseId) {
                item["Warehouse"] = buildWarehouse(warehouse);
                break;
            }
        }
    }
    return item;
}

Json buildWarehouseAssignmentArray(
    WarehouseAssignment[] assignments
) {
    Json list = Json.emptyArray;
    foreach (assignment; assignments) {
        list ~= buildAssignment(assignment, false, []);
    }
    return list;
}

Json buildAssignmentArray(
    WarehouseAssignment[] entries,
    bool includeWarehouse,
    Warehouse[] warehouses
) {
    Json list = Json.emptyArray;
    foreach (entry; entries) {
        list ~= buildAssignment(entry, includeWarehouse, warehouses);
    }
    return list;
}

// Json toJson(WarehouseAssignment[] entries) {
//     Json array = Json.emptyArray;
//     foreach (entry; entries) {
//         Json item = Json.emptyObject;
//         item["id"] = Json(entry.id);
//         item["materialId"] = Json(entry.materialId);
//         item["warehouseId"] = Json(entry.warehouseId);
//         array ~= item;
//     }
//     return array;
// }
