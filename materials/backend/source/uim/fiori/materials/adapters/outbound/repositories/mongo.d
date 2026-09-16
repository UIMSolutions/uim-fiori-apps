module uim.fiori.materials.adapters.outbound.repositories.mongo;
import std.conv : to;
import std.uuid : randomUUID;
import vibe.data.bson;
import vibe.db.mongo.mongo;
import uim.fiori.materials;

@safe:
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
            result ~= Material.fromBson(doc);
        }
        return result;
    }

    override Material createMaterial(Material material) {
        auto newMaterial = material;
        if (newMaterial.id.length == 0) {
            newMaterial.id = randomUUID().toString();
        }
        _materials.insertOne(newMaterial.toBson());
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
        return Material.fromBson(doc);
    }

    override MaterialPlan[] listPlans() {
        MaterialPlan[] result;
        foreach (doc; _plans.find()) {
            result ~= MaterialPlan.fromBson(doc);
        }
        return result;
    }

    override MaterialPlan createPlan(MaterialPlan plan) {
        auto newPlan = plan;
        if (newPlan.id.length == 0) {
            newPlan.id = randomUUID().toString();
        }
        _plans.insertOne(newPlan.toBson());
        return newPlan;
    }

    override Warehouse[] listWarehouses() {
        Warehouse[] result;
        foreach (doc; _warehouses.find()) {
            result ~= Warehouse.fromBson(doc);
        }
        return result;
    }

    override WarehouseAssignment[] listAssignments() {
        WarehouseAssignment[] result;
        foreach (doc; _assignments.find()) {
            result ~= WarehouseAssignment.fromBson(doc);
        }
        return result;
    }

    override WarehouseAssignment createAssignment(WarehouseAssignment assignment) {
        auto newAssignment = assignment;
        if (newAssignment.id.length == 0) {
            newAssignment.id = randomUUID().toString();
        }
        _assignments.insertOne(newAssignment.toBson());
        return newAssignment;
    }

    override StockEntry[] listStocks() {
        StockEntry[] result;
        foreach (doc; _stocks.find()) {
            result ~= StockEntry.fromBson(doc);
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
        _materials.insertOne(m1.toBson());
        _materials.insertOne(m2.toBson());
        _warehouses.insertOne(w1.toBson());
        _warehouses.insertOne(w2.toBson());
        _plans.insertOne(MaterialPlan(randomUUID().toString(), m1.id, "2026-10-01", 600).toBson());
        _plans.insertOne(MaterialPlan(randomUUID().toString(), m2.id, "2026-10-05", 1200).toBson());
        _assignments.insertOne(WarehouseAssignment(randomUUID().toString(), m1.id, w1.id).toBson());
        _assignments.insertOne(WarehouseAssignment(randomUUID().toString(), m2.id, w2.id).toBson());
        _stocks.insertOne(StockEntry(m1.id, 1000, 250).toBson());
        _stocks.insertOne(StockEntry(m2.id, 5300, 400).toBson());
    }

}
