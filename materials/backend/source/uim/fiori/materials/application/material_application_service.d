module uim.fiori.materials.application.material_application_service;

import uim.fiori.materials;

@safe:
class MaterialApplicationService {
private:
    MaterialPort _materials;
    PlanningPort _planning;
    WarehousePort _warehouses;
    StockPort _stocks;
    SupplierPort _suppliers;

public:
    this(MaterialPort materials, PlanningPort planning, WarehousePort warehouses, StockPort stocks, SupplierPort suppliers) {
        _materials = materials;
        _planning = planning;
        _warehouses = warehouses;
        _stocks = stocks;
        _suppliers = suppliers;
    }
    Material[] listMaterials() {
        return _materials.listMaterials();
    }
    Material createMaterial(Material material) {
        return _materials.createMaterial(material);
    }
    MaterialPlan[] listPlans() {
        return _planning.listPlans();
    }
    Supplier[] listSuppliers() {
        return _suppliers.listSuppliers();
    }
    MaterialPlan createPlan(MaterialPlan plan) {
        auto material = _materials.findMaterialById(plan.materialId);
        if (material.id.length == 0) {
            throw new Exception("Unknown materialId in planning request");
        }
        return _planning.createPlan(plan);
    }
    Warehouse[] listWarehouses() {
        return _warehouses.listWarehouses();
    }
    WarehouseAssignment[] listAssignments() {
        return _warehouses.listAssignments();
    }
    WarehouseAssignment createAssignment(WarehouseAssignment assignment) {
        auto material = _materials.findMaterialById(assignment.materialId);
        if (material.id.length == 0) {
            throw new Exception("Unknown materialId in assignment request");
        }
        bool warehouseFound = false;
        foreach (warehouse; _warehouses.listWarehouses()) {
            if (warehouse.id == assignment.warehouseId) {
                warehouseFound = true;
                break;
            }
        }
        if (!warehouseFound) {
            throw new Exception("Unknown warehouseId in assignment request");
        }
        return _warehouses.createAssignment(assignment);
    }
    StockEvaluation[] listStockEvaluations() {
        return evaluateStock(_materials.listMaterials(), _stocks.listStocks());
    }
}
