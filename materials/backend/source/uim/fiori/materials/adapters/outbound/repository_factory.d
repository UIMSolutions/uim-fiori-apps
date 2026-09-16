module uim.fiori.materials.adapters.outbound.repository_factory;
import std.string : fromStringz, toLower, toStringz;
import core.stdc.stdlib : getenv;
import uim.fiori.materials;
import std.process : environment;
@safe:
struct RepositoryBundle {
    MaterialPort materials;
    PlanningPort planning;
    WarehousePort warehouses;
    StockPort stocks;
    SupplierPort suppliers;
    string selectedAdapter;
}

RepositoryBundle createRepositoryBundle() {
    auto adapter = environment.get("MATERIAL_PERSISTENCE", "memory").toLower();
    Object repository;
    string selectedAdapter;
    switch (adapter) {
        case "memory":
            repository = new InMemoryRepository();
            selectedAdapter = "memory";
            break;
        case "file":
            auto filePath = environment.get("MATERIAL_FILE_PATH", "./data/material-store.json");
            repository = new FileRepository(filePath);
            selectedAdapter = "file";
            break;
        case "mongodb":
            auto mongoUri = environment.get("MATERIAL_MONGO_URI", "mongodb://127.0.0.1:27017/?safe=true");
            auto mongoDbName = environment.get("MATERIAL_MONGO_DB", "material_service");
            repository = new MongoRepository(mongoUri, mongoDbName);
            selectedAdapter = "mongodb";
            break;
        default:
            repository = new InMemoryRepository();
            selectedAdapter = "memory";
            break;
    }
    return RepositoryBundle(
        cast(MaterialPort) repository,
        cast(PlanningPort) repository,
        cast(WarehousePort) repository,
        cast(StockPort) repository,
        cast(SupplierPort) repository,
        selectedAdapter
    );
}
