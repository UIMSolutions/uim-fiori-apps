module uim.fiori.materials.domain.entities.stockevaluation;

import uim.fiori.materials;

@safe:
struct StockEvaluation {
    string materialId;
    string materialName;
    double onHand;
    double reserved;
    double available;
    double targetStock;
    string status;
    Json toJson() const {
        Json item = Json.emptyObject
            .set("MaterialID", Json(materialId))
            .set("MaterialName", Json(materialName))
            .set("OnHand", Json(onHand))
            .set("Reserved", Json(reserved))
            .set("Available", Json(available))
            .set("TargetStock", Json(targetStock))
            .set("Status", Json(status));
        return item;
    }
    static StockEvaluation fromJson(Json item) {
        StockEvaluation evaluation;
        evaluation.materialId = item["MaterialID"].get!string;
        evaluation.materialName = item["MaterialName"].get!string;
        evaluation.onHand = item["OnHand"].get!double;
        evaluation.reserved = item["Reserved"].get!double;
        evaluation.available = item["Available"].get!double;
        evaluation.targetStock = item["TargetStock"].get!double;
        evaluation.status = item["Status"].get!string;
        return evaluation;
    }
}
Json buildEvaluation(StockEvaluation evaluation) {
    Json item = evaluation.toJson();
    return item;
}
Json buildStockEvaluation(
    StockEvaluation evaluation
) {
    return evaluation.toJson();
}
Json buildStockEvaluationArray(
    StockEvaluation[] evaluations
) {
    Json list = Json.emptyArray;
    foreach (evaluation; evaluations) {
        list ~= buildStockEvaluation(evaluation);
    }
    return list;
}
Json buildEvaluationArray(StockEvaluation[] entries) {
    Json result = Json.emptyArray;
    foreach (entry; entries) {
        result ~= buildEvaluation(entry);
    }
    return result;
}
