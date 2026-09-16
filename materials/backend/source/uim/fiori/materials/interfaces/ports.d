module uim.fiori.materials.interfaces.ports;

import uim.fiori.materials.domain.entities;

@safe:
interface MaterialPort {
    Material[] listMaterials();
    Material createMaterial(Material material);
    Material findMaterialById(string materialId);
}

interface PlanningPort {
    MaterialPlan[] listPlans();
    MaterialPlan createPlan(MaterialPlan plan);
}

interface WarehousePort {
    Warehouse[] listWarehouses();
    WarehouseAssignment[] listAssignments();
    WarehouseAssignment createAssignment(WarehouseAssignment assignment);
}

interface StockPort {
    StockEntry[] listStocks();
}

interface SupplierPort {
    Supplier[] listSuppliers();
}
