module landscape.backend.tests.landscape_service_test;
import landscape_backend.adapters.outbound.inmemory.memory_landscape_repository;
import landscape_backend.application.landscape_service;
unittest {
    auto repo = new InMemoryLandscapeRepository();
    auto service = new LandscapeService(repo);
    auto systems = service.listSystems();
    assert(systems.length > 0);
    auto kpis = service.buildKPIs();
    assert(kpis.length == 3);
    auto matrix = service.buildMatrixCells();
    assert(matrix.length > 0);
}
