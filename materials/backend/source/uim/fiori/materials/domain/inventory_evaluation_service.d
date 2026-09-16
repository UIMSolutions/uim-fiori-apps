module uim.fiori.materials.domain.inventory_evaluation_service;
import uim.fiori.materials.domain.entities;

@safe:
StockEvaluation[] evaluateStock(Material[] materials, StockEntry[] stocks) {
    StockEvaluation[] evaluations;
    foreach (material; materials) {
        StockEntry selected;
        bool stockFound = false;
        foreach (stock; stocks) {
            if (stock.materialId == material.id) {
                selected = stock;
                stockFound = true;
                break;
            }
        }
        if (!stockFound) {
            selected = StockEntry(material.id, 0, 0);
        }
        auto available = selected.quantityOnHand - selected.reservedQuantity;
        auto status = available < material.targetStock ? "CRITICAL" : "OK";
        evaluations ~= StockEvaluation(
            material.id,
            material.materialName,
            selected.quantityOnHand,
            selected.reservedQuantity,
            available,
            material.targetStock,
            status
        );
    }
    return evaluations;
}
