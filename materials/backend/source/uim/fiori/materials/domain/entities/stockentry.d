module uim.fiori.materials.domain.entities.stockentry;

import uim.fiori.materials;

@safe:
struct StockEntry {
    string materialId;
    double quantityOnHand;
    double reservedQuantity;

    Json toJson() const {
        Json item = Json.emptyObject;
        item["MaterialID"] = Json(materialId);
        item["QuantityOnHand"] = Json(quantityOnHand);
        item["ReservedQuantity"] = Json(reservedQuantity);
        return item;
    }
    static StockEntry fromJson(Json item) {
        StockEntry entry;
        entry.materialId = item["MaterialID"].get!string;
        entry.quantityOnHand = item["QuantityOnHand"].get!double;
        entry.reservedQuantity = item["ReservedQuantity"].get!double;
        return entry;
    }
    Bson toBson() const {
        Bson doc = Bson.emptyObject;
        doc["materialId"] = Bson(materialId);
        doc["quantityOnHand"] = Bson(quantityOnHand);
        doc["reservedQuantity"] = Bson(reservedQuantity);
        return doc;
    }
    static StockEntry fromBson(Bson doc) {
        StockEntry entry;
        entry.materialId = readString(doc, "materialId");
        entry.quantityOnHand = readDouble(doc, "quantityOnHand");
        entry.reservedQuantity = readDouble(doc, "reservedQuantity");
        return entry;
    }
}
Json buildStockEntry(
    StockEntry entry
) {
    return entry.toJson();
}
Json buildStockEntryArray(
    StockEntry[] entries
) {
    Json list = Json.emptyArray;
    foreach (entry; entries) {
        list ~= buildStockEntry(entry);
    }
    return list;
}

// Json toJson(StockEntry[] entries) {
//         Json array = Json.emptyArray;
//         foreach (entry; entries) {
//             Json item = Json.emptyObject;
//             item["materialId"] = Json(entry.materialId);
//             item["quantityOnHand"] = Json(entry.quantityOnHand);
//             item["reservedQuantity"] = Json(entry.reservedQuantity);
//             array ~= item;
//         }
//         return array;
//     }