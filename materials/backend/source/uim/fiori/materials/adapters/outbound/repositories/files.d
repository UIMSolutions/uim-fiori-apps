module uim.fiori.materials.adapters.outbound.repositories.files;
import std.file : exists, mkdirRecurse, readText, write;
import std.path : dirName;
import std.uuid : randomUUID;
import vibe.data.json;
import uim.fiori.materials;

@safe:
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
        root["materials"] = _materials.toJson();
        root["plans"] = _plans.toJson();
        root["warehouses"] = _warehouses.toJson();
        root["assignments"] = _assignments.toJson();
        root["stocks"] = _stocks.toJson();
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
        foreach (item; input.toArray) {
            Material material;
            material.id = item.getString("id");
            material.materialName = item.getString("name");
            material.description = item.getString("description");
            material.targetStock = item.getDouble("targetStock");
            result ~= material;
        }
        return result;
    }
    MaterialPlan[] parsePlans(Json input) {
        MaterialPlan[] result;
        foreach (item; input.toArray) {
            MaterialPlan plan;
            plan.id = item.getString("id");
            plan.materialId = item.getString("materialId");
            plan.plannedDate = item.getString("plannedDate");
            plan.plannedQuantity = item.getDouble("plannedQuantity");
            result ~= plan;
        }
        return result;
    }
    Warehouse[] parseWarehouses(Json input) {
        Warehouse[] result;
        foreach (item; input.toArray) {
            Warehouse warehouse;
            warehouse.id = item.getString("id");
            warehouse.name = item.getString("name");
            warehouse.location = item.getString("location");
            result ~= warehouse;
        }
        return result;
    }

    WarehouseAssignment[] parseAssignments(Json input) {
        WarehouseAssignment[] result;
        foreach (item; input.toArray) {
            WarehouseAssignment assignment;
            assignment.id = item.getString("id");
            assignment.materialId = item.getString("materialId");
            assignment.warehouseId = item.getString("warehouseId");
            result ~= assignment;
        }
        return result;
    }

    StockEntry[] parseStocks(Json input) {
        StockEntry[] result;
        foreach (item; input.toArray) {
            StockEntry stock;
            stock.materialId = item.getString("materialId");
            stock.quantityOnHand = item.getDouble("quantityOnHand");
            stock.reservedQuantity = item.getDouble("reservedQuantity");
            result ~= stock;
        }
        return result;
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
