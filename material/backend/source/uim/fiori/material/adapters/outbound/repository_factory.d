module uim.fiori.material.adapters.outbound.repository_factory;
import std.string : fromStringz, toLower, toStringz;
import core.stdc.stdlib : getenv;
import uim.fiori.material;
struct RepositoryBundle {
    MaterialPort materials;
    PlanningPort planning;
    WarehousePort warehouses;
    StockPort stocks;
    string selectedAdapter;
}
RepositoryBundle createRepositoryBundle() {
    auto adapter = getEnv("MATERIAL_PERSISTENCE", "inmemory").toLower();
    Object repository;
    string selectedAdapter;
    switch (adapter) {
        case "inmemory":
            repository = new InMemoryRepository();
            selectedAdapter = "inmemory";
            break;
        case "file":
            auto filePath = getEnv("MATERIAL_FILE_PATH", "./data/material-store.json");
            repository = new FileRepository(filePath);
            selectedAdapter = "file";
            break;
        case "mongodb":
            auto mongoUri = getEnv("MATERIAL_MONGO_URI", "mongodb://127.0.0.1:27017/?safe=true");
            auto mongoDbName = getEnv("MATERIAL_MONGO_DB", "material_service");
            repository = new MongoRepository(mongoUri, mongoDbName);
            selectedAdapter = "mongodb";
            break;
        default:
            repository = new InMemoryRepository();
            selectedAdapter = "inmemory";
            break;
    }
    return RepositoryBundle(
        cast(MaterialPort) repository,
        cast(PlanningPort) repository,
        cast(WarehousePort) repository,
        cast(StockPort) repository,
        selectedAdapter
    );
}
private string getEnv(string name, string fallback = "") {
    auto ptr = getenv(toStringz(name));
    if (ptr is null) {
        return fallback;
    }
    return fromStringz(ptr).idup;
}
