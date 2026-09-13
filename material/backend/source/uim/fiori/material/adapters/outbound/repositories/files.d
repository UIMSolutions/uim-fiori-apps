module uim.fiori.material.adapters.outbound.repositories.files;
import std.file : exists, mkdirRecurse, readText, write;
import std.path : dirName;
import std.uuid : randomUUID;
import vibe.data.json;
import uim.fiori.material.domain.entities;
import uim.fiori.material.domain.ports;
class FileRepository : MaterialPort, PlanningPort, WarehousePort, StockPort {
private:
    string _storePath;
    Material[] _materials;
    MaterialPlan[] _plans;
    Warehouse[] _warehouses;
    WarehouseAssignment[] _assignments;
    StockEntry[] _stocks;
public:
    this(string storePath) {
        _storePath = storePath;
        load();
    }
    override Material[] listMaterials() {
        return _materials.dup;
    }
    override Material createMaterial(Material material) {
        auto newMaterial = material;
        if (newMaterial.id.length == 0) {
            newMaterial.id = randomUUID().toString();
        }
        _materials ~= newMaterial;
        _stocks ~= StockEntry(newMaterial.id, 0, 0);
        flush();
        return newMaterial;
    }
    override Material findMaterialById(string materialId) {
        foreach (material; _materials) {
            if (material.id == materialId) {
                return material;
            }
        }
        return Material.init;
    }
    override MaterialPlan[] listPlans() {
        return _plans.dup;
    }
    override MaterialPlan createPlan(MaterialPlan plan) {
        auto newPlan = plan;
        if (newPlan.id.length == 0) {
            newPlan.id = randomUUID().toString();
        }
        _plans ~= newPlan;
        flush();
        return newPlan;
    }
    override Warehouse[] listWarehouses() {
        return _warehouses.dup;
    }
    override WarehouseAssignment[] listAssignments() {
        return _assignments.dup;
    }
    override WarehouseAssignment createAssignment(WarehouseAssignment assignment) {
        auto newAssignment = assignment;
        if (newAssignment.id.length == 0) {
            newAssignment.id = randomUUID().toString();
        }
        _assignments ~= newAssignment;
        flush();
        return newAssignment;
    }
    override StockEntry[] listStocks() {
        return _stocks.dup;
    }
private:
    void load() {
        if (!exists(_storePath)) {
            seed();
            flush();
            return;
        }
        auto root = parseJsonString(readText(_storePath));
        _materials = parseMaterials(readArray(root, "materials"));
        _plans = parsePlans(readArray(root, "plans"));
        _warehouses = parseWarehouses(readArray(root, "warehouses"));
        _assignments = parseAssignments(readArray(root, "assignments"));
        _stocks = parseStocks(readArray(root, "stocks"));
    }

    void flush() {
        auto parent = dirName(_storePath);
        if (parent.length > 0 && !exists(parent)) {
            mkdirRecurse(parent);
        }
        Json root = Json.emptyObject;
        root["materials"] = materialsToJson(_materials);
        root["plans"] = plansToJson(_plans);
        root["warehouses"] = warehousesToJson(_warehouses);
        root["assignments"] = assignmentsToJson(_assignments);
        root["stocks"] = stocksToJson(_stocks);
        write(_storePath, root.toPrettyString());
    }

    void seed() {
        auto m1 = Material(randomUUID().toString(), "Aluminiumblech", "Rohmaterial fuer Gehaeuse", 1200);
        auto m2 = Material(randomUUID().toString(), "Schraube M8", "Standard Verbindungselement", 5000);
        _materials = [m1, m2];
        _warehouses = [
            Warehouse(randomUUID().toString(), "Zentrallager Nord", "Hamburg"),
            Warehouse(randomUUID().toString(), "Werklager Sued", "Nuernberg")
        ];
        _plans = [
            MaterialPlan(randomUUID().toString(), m1.id, "2026-10-01", 600),
            MaterialPlan(randomUUID().toString(), m2.id, "2026-10-05", 1200)
        ];
        _assignments = [
            WarehouseAssignment(randomUUID().toString(), m1.id, _warehouses[0].id),
            WarehouseAssignment(randomUUID().toString(), m2.id, _warehouses[1].id)
        ];
        _stocks = [
            StockEntry(m1.id, 1000, 250),
            StockEntry(m2.id, 5300, 400)
        ];
    }
    Json readArray(Json root, string key) {
        if (key in root && root[key].type == Json.Type.array) {
            return root[key];
        }
        return Json.emptyArray;
    }
    Material[] parseMaterials(Json input) {
        Material[] result;
        foreach (item; input) {
            Material material;
            material.id = readString(item, "id");
            material.name = readString(item, "name");
            material.description = readString(item, "description");
            material.targetStock = readDouble(item, "targetStock");
            result ~= material;
        }
        return result;
    }
    MaterialPlan[] parsePlans(Json input) {
        MaterialPlan[] result;
        foreach (item; input) {
            MaterialPlan plan;
            plan.id = readString(item, "id");
            plan.materialId = readString(item, "materialId");
            plan.plannedDate = readString(item, "plannedDate");
            plan.plannedQuantity = readDouble(item, "plannedQuantity");
            result ~= plan;
        }
        return result;
    }
    Warehouse[] parseWarehouses(Json input) {
        Warehouse[] result;
        foreach (item; input) {
            Warehouse warehouse;
            warehouse.id = readString(item, "id");
            warehouse.name = readString(item, "name");
            warehouse.location = readString(item, "location");
            result ~= warehouse;
        }
        return result;
    }
    WarehouseAssignment[] parseAssignments(Json input) {
        WarehouseAssignment[] result;
        foreach (item; input) {
            WarehouseAssignment assignment;
            assignment.id = readString(item, "id");
            assignment.materialId = readString(item, "materialId");
            assignment.warehouseId = readString(item, "warehouseId");
            result ~= assignment;
        }
        return result;
    }
    StockEntry[] parseStocks(Json input) {
        StockEntry[] result;
        foreach (item; input) {
            StockEntry stock;
            stock.materialId = readString(item, "materialId");
            stock.quantityOnHand = readDouble(item, "quantityOnHand");
            stock.reservedQuantity = readDouble(item, "reservedQuantity");
            result ~= stock;
        }
        return result;
    }
    Json materialsToJson(Material[] entries) {
        Json array = Json.emptyArray;
        foreach (entry; entries) {
            Json item = Json.emptyObject;
            item["id"] = Json(entry.id);
            item["name"] = Json(entry.name);
            item["description"] = Json(entry.description);
            item["targetStock"] = Json(entry.targetStock);
            array ~= item;
        }
        return array;
    }
    Json plansToJson(MaterialPlan[] entries) {
        Json array = Json.emptyArray;
        foreach (entry; entries) {
            Json item = Json.emptyObject;
            item["id"] = Json(entry.id);
            item["materialId"] = Json(entry.materialId);
            item["plannedDate"] = Json(entry.plannedDate);
            item["plannedQuantity"] = Json(entry.plannedQuantity);
            array ~= item;
        }
        return array;
    }
    Json warehousesToJson(Warehouse[] entries) {
        Json array = Json.emptyArray;
        foreach (entry; entries) {
            Json item = Json.emptyObject;
            item["id"] = Json(entry.id);
            item["name"] = Json(entry.name);
            item["location"] = Json(entry.location);
            array ~= item;
        }
        return array;
    }
    Json assignmentsToJson(WarehouseAssignment[] entries) {
        Json array = Json.emptyArray;
        foreach (entry; entries) {
            Json item = Json.emptyObject;
            item["id"] = Json(entry.id);
            item["materialId"] = Json(entry.materialId);
            item["warehouseId"] = Json(entry.warehouseId);
            array ~= item;
        }
        return array;
    }
    Json stocksToJson(StockEntry[] entries) {
        Json array = Json.emptyArray;
        foreach (entry; entries) {
            Json item = Json.emptyObject;
            item["materialId"] = Json(entry.materialId);
            item["quantityOnHand"] = Json(entry.quantityOnHand);
            item["reservedQuantity"] = Json(entry.reservedQuantity);
            array ~= item;
        }
        return array;
    }
    string readString(Json payload, string key, string fallback = "") {
        if (key in payload) {
            return payload[key].get!string;
        }
        return fallback;
    }
    double readDouble(Json payload, string key, double fallback = 0) {
        if (key in payload) {
            return payload[key].get!double;
        }
        return fallback;
    }
}
