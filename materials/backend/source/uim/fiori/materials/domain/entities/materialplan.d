module uim.fiori.materials.domain.entities.materialplan;

import uim.fiori.materials;

@safe:
struct MaterialPlan {
    string id;
    string materialId;
    string plannedDate;
    double plannedQuantity;

    Json toJson() const {
        Json item = Json.emptyObject;
        item["ID"] = Json(id);
        item["MaterialID"] = Json(materialId);
        item["PlannedDate"] = Json(plannedDate);
        item["PlannedQuantity"] = Json(plannedQuantity);
        return item;
    }

    static MaterialPlan fromJson(Json item) {
        MaterialPlan plan;
        plan.id = item["ID"].get!string;
        plan.materialId = item["MaterialID"].get!string;
        plan.plannedDate = item["PlannedDate"].get!string;
        plan.plannedQuantity = item["PlannedQuantity"].get!double;
        return plan;
    }

    Bson toBson() const {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(id);
        doc["materialId"] = Bson(materialId);
        doc["plannedDate"] = Bson(plannedDate);
        doc["plannedQuantity"] = Bson(plannedQuantity);
        return doc;
    }

    static MaterialPlan fromBson(Bson doc) {
        MaterialPlan plan;
        plan.id = readString(doc, "id");
        plan.materialId = readString(doc, "materialId");
        plan.plannedDate = readString(doc, "plannedDate");
        plan.plannedQuantity = readDouble(doc, "plannedQuantity");
        return plan;
    }
}

Json buildMaterialPlan(MaterialPlan plan) {
    return plan.toJson();
}

Json buildMaterialPlanArray(
    MaterialPlan[] plans
) {
    Json list = Json.emptyArray;
    foreach (plan; plans) {
        list ~= buildMaterialPlan(plan);
    }
    return list;
}

Json buildPlan(MaterialPlan plan) {
    Json item = plan.toJson();
    return item;
}

Json buildPlanArray(MaterialPlan[] plans) {
    Json list = Json.emptyArray;
    foreach (plan; plans) {
        list ~= buildPlan(plan);
    }
    return list;
}

// Json toJson(MaterialPlan[] entries) {
//     Json array = Json.emptyArray;
//     foreach (entry; entries) {
//         Json item = Json.emptyObject;
//         item["id"] = Json(entry.id);
//         item["materialId"] = Json(entry.materialId);
//         item["plannedDate"] = Json(entry.plannedDate);
//         item["plannedQuantity"] = Json(entry.plannedQuantity);
//         array ~= item;
//     }
//     return array;
// }
