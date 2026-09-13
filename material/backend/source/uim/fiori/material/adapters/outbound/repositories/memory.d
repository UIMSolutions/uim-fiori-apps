module uim.fiori.material.adapters.outbound.repositories.memory;
import std.uuid : randomUUID;
import uim.fiori.material.domain.entities;
import uim.fiori.material.domain.ports;
class InMemoryRepository : MaterialPort, PlanningPort, WarehousePort, StockPort {
private:
    Material[] _materials;
    MaterialPlan[] _plans;
    Warehouse[] _warehouses;
    WarehouseAssignment[] _assignments;
    StockEntry[] _stocks;
public:
    this() {
        seed();
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
        return newAssignment;
    }
    override StockEntry[] listStocks() {
        return _stocks.dup;
    }
private:
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
}
