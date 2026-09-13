module uim.fiori.material.adapters.outbound.repositories.mongo;
import std.conv : to;
import std.uuid : randomUUID;
import vibe.data.bson;
import vibe.db.mongo.mongo;
import uim.fiori.material.domain.entities;
import uim.fiori.material.domain.ports;
class MongoRepository : MaterialPort, PlanningPort, WarehousePort, StockPort {
private:
    MongoClient _client;
    MongoCollection _materials;
    MongoCollection _plans;
    MongoCollection _warehouses;
    MongoCollection _assignments;
    MongoCollection _stocks;
public:
    this(string mongoUri, string dbName) {
        _client = connectMongoDB(mongoUri);
        _materials = _client.getCollection(dbName ~ ".materials");
        _plans = _client.getCollection(dbName ~ ".material_plans");
        _warehouses = _client.getCollection(dbName ~ ".warehouses");
        _assignments = _client.getCollection(dbName ~ ".warehouse_assignments");
        _stocks = _client.getCollection(dbName ~ ".stocks");
        seedIfEmpty();
    }
    override Material[] listMaterials() {
        Material[] result;
        foreach (doc; _materials.find()) {
            result ~= materialFromBson(doc);
        }
        return result;
    }
    override Material createMaterial(Material material) {
        auto newMaterial = material;
        if (newMaterial.id.length == 0) {
            newMaterial.id = randomUUID().toString();
        }
        _materials.insertOne(materialToBson(newMaterial));
        Bson stock = Bson.emptyObject;
        stock["materialId"] = Bson(newMaterial.id);
        stock["quantityOnHand"] = Bson(0.0);
        stock["reservedQuantity"] = Bson(0.0);
        _stocks.insertOne(stock);
        return newMaterial;
    }
    override Material findMaterialById(string materialId) {
        auto doc = _materials.findOne(["id": materialId]);
        if (doc.type == Bson.Type.null_) {
            return Material.init;
        }
        return materialFromBson(doc);
    }
    override MaterialPlan[] listPlans() {
        MaterialPlan[] result;
        foreach (doc; _plans.find()) {
            result ~= planFromBson(doc);
        }
        return result;
    }
    override MaterialPlan createPlan(MaterialPlan plan) {
        auto newPlan = plan;
        if (newPlan.id.length == 0) {
            newPlan.id = randomUUID().toString();
        }
        _plans.insertOne(planToBson(newPlan));
        return newPlan;
    }
    override Warehouse[] listWarehouses() {
        Warehouse[] result;
        foreach (doc; _warehouses.find()) {
            result ~= warehouseFromBson(doc);
        }
        return result;
    }
    override WarehouseAssignment[] listAssignments() {
        WarehouseAssignment[] result;
        foreach (doc; _assignments.find()) {
            result ~= assignmentFromBson(doc);
        }
        return result;
    }
    override WarehouseAssignment createAssignment(WarehouseAssignment assignment) {
        auto newAssignment = assignment;
        if (newAssignment.id.length == 0) {
            newAssignment.id = randomUUID().toString();
        }
        _assignments.insertOne(assignmentToBson(newAssignment));
        return newAssignment;
    }
    override StockEntry[] listStocks() {
        StockEntry[] result;
        foreach (doc; _stocks.find()) {
            result ~= stockFromBson(doc);
        }
        return result;
    }
private:
    void seedIfEmpty() {
        bool hasDocuments = false;
        foreach (_; _materials.find().limit(1)) {
            hasDocuments = true;
            break;
        }
        if (hasDocuments) {
            return;
        }
        auto m1 = Material(randomUUID().toString(), "Aluminiumblech", "Rohmaterial fuer Gehaeuse", 1200);
        auto m2 = Material(randomUUID().toString(), "Schraube M8", "Standard Verbindungselement", 5000);
        auto w1 = Warehouse(randomUUID().toString(), "Zentrallager Nord", "Hamburg");
        auto w2 = Warehouse(randomUUID().toString(), "Werklager Sued", "Nuernberg");
        _materials.insertOne(materialToBson(m1));
        _materials.insertOne(materialToBson(m2));
        _warehouses.insertOne(warehouseToBson(w1));
        _warehouses.insertOne(warehouseToBson(w2));
        _plans.insertOne(planToBson(MaterialPlan(randomUUID().toString(), m1.id, "2026-10-01", 600)));
        _plans.insertOne(planToBson(MaterialPlan(randomUUID().toString(), m2.id, "2026-10-05", 1200)));
        _assignments.insertOne(assignmentToBson(WarehouseAssignment(randomUUID().toString(), m1.id, w1.id)));
        _assignments.insertOne(assignmentToBson(WarehouseAssignment(randomUUID().toString(), m2.id, w2.id)));
        _stocks.insertOne(stockToBson(StockEntry(m1.id, 1000, 250)));
        _stocks.insertOne(stockToBson(StockEntry(m2.id, 5300, 400)));
    }
    Bson materialToBson(Material material) {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(material.id);
        doc["name"] = Bson(material.name);
        doc["description"] = Bson(material.description);
        doc["targetStock"] = Bson(material.targetStock);
        return doc;
    }
    Material materialFromBson(Bson doc) {
        Material material;
        material.id = readString(doc, "id");
        material.name = readString(doc, "name");
        material.description = readString(doc, "description");
        material.targetStock = readDouble(doc, "targetStock");
        return material;
    }
    Bson planToBson(MaterialPlan plan) {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(plan.id);
        doc["materialId"] = Bson(plan.materialId);
        doc["plannedDate"] = Bson(plan.plannedDate);
        doc["plannedQuantity"] = Bson(plan.plannedQuantity);
        return doc;
    }
    MaterialPlan planFromBson(Bson doc) {
        MaterialPlan plan;
        plan.id = readString(doc, "id");
        plan.materialId = readString(doc, "materialId");
        plan.plannedDate = readString(doc, "plannedDate");
        plan.plannedQuantity = readDouble(doc, "plannedQuantity");
        return plan;
    }
    Bson warehouseToBson(Warehouse warehouse) {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(warehouse.id);
        doc["name"] = Bson(warehouse.name);
        doc["location"] = Bson(warehouse.location);
        return doc;
    }
    Warehouse warehouseFromBson(Bson doc) {
        Warehouse warehouse;
        warehouse.id = readString(doc, "id");
        warehouse.name = readString(doc, "name");
        warehouse.location = readString(doc, "location");
        return warehouse;
    }
    Bson assignmentToBson(WarehouseAssignment assignment) {
        Bson doc = Bson.emptyObject;
        doc["id"] = Bson(assignment.id);
        doc["materialId"] = Bson(assignment.materialId);
        doc["warehouseId"] = Bson(assignment.warehouseId);
        return doc;
    }
    WarehouseAssignment assignmentFromBson(Bson doc) {
        WarehouseAssignment assignment;
        assignment.id = readString(doc, "id");
        assignment.materialId = readString(doc, "materialId");
        assignment.warehouseId = readString(doc, "warehouseId");
        return assignment;
    }
    Bson stockToBson(StockEntry stock) {
        Bson doc = Bson.emptyObject;
        doc["materialId"] = Bson(stock.materialId);
        doc["quantityOnHand"] = Bson(stock.quantityOnHand);
        doc["reservedQuantity"] = Bson(stock.reservedQuantity);
        return doc;
    }
    StockEntry stockFromBson(Bson doc) {
        StockEntry stock;
        stock.materialId = readString(doc, "materialId");
        stock.quantityOnHand = readDouble(doc, "quantityOnHand");
        stock.reservedQuantity = readDouble(doc, "reservedQuantity");
        return stock;
    }
    string readString(Bson doc, string key, string fallback = "") {
        Bson value;
        if (tryGet(doc, key, value)) {
            return value.to!string;
        }
        return fallback;
    }
    double readDouble(Bson doc, string key, double fallback = 0) {
        Bson value;
        if (!tryGet(doc, key, value)) {
            return fallback;
        }
        switch (value.type) with (Bson.Type) {
            case double_:
                return value.get!double;
            case int_:
                return cast(double) value.get!int;
            case long_:
                return cast(double) value.get!long;
            case string:
                return value.to!double;
            default:
                return fallback;
        }
    }
    bool tryGet(Bson doc, string key, out Bson value) {
        if (doc.type != Bson.Type.object) {
            return false;
        }
        auto map = doc.get!(Bson[string]);
        if (auto found = key in map) {
            value = *found;
            return true;
        }
        return false;
    }
}
