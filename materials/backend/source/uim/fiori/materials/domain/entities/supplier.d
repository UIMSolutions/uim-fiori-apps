module uim.fiori.materials.domain.entities.supplier;

import uim.fiori.materials;

@safe:
struct Supplier {
    string id;
    string name;
    string contactInfo;
    string description;
    Json toJson() const {
        Json item = Json.emptyObject;
        item["ID"] = Json(id);
        item["Name"] = Json(name);
        item["ContactInfo"] = Json(contactInfo);
        item["Description"] = Json(description);
        return item;
    }
    static Supplier fromJson(Json item) {
        Supplier supplier;
        supplier.id = item["ID"].get!string;
        supplier.name = item["Name"].get!string;
        supplier.contactInfo = item["ContactInfo"].get!string;
        supplier.description = item["Description"].get!string;
        return supplier;
    }
}
Json buildSupplier(
    Supplier supplier
) {
    return supplier.toJson();
}
Json buildSupplierArray(
    Supplier[] suppliers
) {
    Json list = Json.emptyArray;
    foreach (supplier; suppliers) {
        list ~= buildSupplier(supplier);
    }
    return list;
}   
