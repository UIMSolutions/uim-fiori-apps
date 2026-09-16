module material.backend.tests.inventory_evaluation_test;
import std.algorithm.searching : countUntil;
import material_backend.domain.entities;
import material_backend.domain.inventory_evaluation_service;
unittest {
    auto materials = [
        Material("M-1", "Testmaterial", "", 100)
    ];
    auto stocks = [
        StockEntry("M-1", 70, 10)
    ];
    auto result = evaluateStock(materials, stocks);
    assert(result.length == 1);
    assert(result[0].available == 60);
    assert(result[0].status == "CRITICAL");
}
