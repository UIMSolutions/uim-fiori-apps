module uim.fiori.material.domain.entities.stockevaluation;
struct StockEvaluation {
    string materialId;
    string materialName;
    double onHand;
    double reserved;
    double available;
    double targetStock;
    string status;
}