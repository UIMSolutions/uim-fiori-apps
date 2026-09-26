/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.solution;

import uim.fiori_blocks;
import uim.fiori_blocks.application.usecases.solution;

mixin(ShowModule!());

@safe:
class SolutionOdataController : OdataController {
  protected ManageSolutionUseCase _useCase;

  this(ManageSolutionUseCase useCase) {
    this._useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/odata/v4/SolutionBlocks*", &getSolutionBlockByIdOrAll);
    // router.get("/api/v1/configs", &handleList);
    // router.get("/api/v1/configs/*", &handleGet);
    // router.put("/api/v1/configs/*", &handleUpdate);
    // router.delete_("/api/v1/configs/*", &handleDelete);
  }

  void getSolutionBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getSolutionBlocks called");
    string filterQuery = req.params.get("$filter", "");

    SolutionBlock[] blocks = _useCase.listBlocks();

    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
  }

  void getSolutionBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getSolutionBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/SolutionBlocks('SB-01')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
      writeln("No specific ID provided, returning all Solution blocks");

      auto filtered = _useCase.listBlocks.map!(b => b.toJson).array.toJson;
      res.headers["OData-Version"] = "4.0";
      res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
      res.writeJsonBody(Json.emptyObject.set("value", filtered));
      return;
    }

    writeln("Extracting raw ID from request path: ", requestPath);
    // 2. ID aus den Klammern extrahieren
    string rawId = requestPath[startIdx + 1 .. endIdx].strip();

    // Anführungszeichen entfernen: 'IF-02' -> IF-02
    if (rawId.startsWith("'") && rawId.endsWith("'") && rawId.length >= 2) {
      rawId = rawId[1 .. $ - 1];
    }

    // 3. Einzelnen Datensatz suchen
    writeln("Searching for Solution block with ID: ", rawId);
    auto match = _useCase.getBlock(rawId);

    if (match.isNull) {
      res.headers["OData-Version"] = "4.0";
      res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
      res.statusCode = HTTPStatus.notFound;
      res.writeJsonBody(["error": "Entity not found"]);
      return;
    }

    // Einzel-Objekt in OData v4 wird OHNE {"value": [...]} Wrapper gesendet!
    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = match.toJson.set("@odata.context", "$metadata#SolutionBlocks/$entity");
    writeln("Response JSON for single Solution block: ", response);
    res.writeJsonBody(response);
  }

}



class SolutionODataController : ODataController {
  protected ManageSolutionUseCase _useCase;

  this(ManageSolutionUseCase useCase) {
    this._useCase = useCase;
  }

  /// GET /EntitySet mit optionaler $expand Option
  Json getEntitySet(string entitySetName, string expand = "") {
    if (entitySetName != "SolutionBlocks") {
      return Json.emptyArray;
    }

    auto blocks = _useCase.listBlocks();
    return blocks.map!(block => block.toJson).array.toJson;
  }

  /// GET /EntitySet('1001') (Einzel-Entität abfragen)
  Json getEntity(string entitySetName, string id, string expand = "") {
    if (entitySetName != "SolutionBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.getBlock(id);
    if (block.isNull) {
      return Json.emptyObject;
    }

    return block.toJson;
  }

  /// POST /EntitySet (Entität erstellen)
  Json createEntity(string entitySetName, Json payload) {
    if (entitySetName != "SolutionBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.createBlock(payload);
    return block.toJson;
  }

  /// PATCH /EntitySet('1001') (Entität teilweise aktualisieren)
  Json updateEntity(string entitySetName, string id, Json payload) {
    if (entitySetName != "SolutionBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.updateBlock(payload.set("ID", id));
    if (block.isNull) {
      return Json.emptyObject;
    }

    return block.toJson;
  }

  /// DELETE /EntitySet('1001') (Entität löschen)
  bool deleteEntity(string entitySetName, string id) {
    if (entitySetName != "SolutionBlocks") {
      return false;
    }

    _useCase.deleteBlock(id);
    return true;
  }

  /// GET /Entities (Alle Entitäten als JSON abrufen)
  Json getEntitiesJson() {
    auto blocks = _useCase.listBlocks();
    return blocks.map!(block => block.toJson).array.toJson;
  }
}
