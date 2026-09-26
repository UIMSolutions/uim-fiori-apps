/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.architecture;

import uim.fiori_blocks;

@safe:

class ArchitectureOdataController : OdataController {
  protected ManageArchitectureUseCase _useCase;

  this(ManageArchitectureUseCase useCase) {
    this._useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/odata/v4/ArchitectureBlocks*", &getArchitectureBlockByIdOrAll);

    // router.post("/api/v1/architectures", &handleCreate);
    // router.get("/api/v1/architectures", &handleList);
    // router.get("/api/v1/architectures/*", &handleGet);
    // router.put("/api/v1/architectures/*", &handleUpdate);
    // router.delete_("/api/v1/architectures/*", &handleDelete);
  }

  void getArchitectureBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getArchitectureBlocks called");
    string filterQuery = req.params.get("$filter", "");

    ArchitectureBlock[] blocks = _useCase.listBlocks;

    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
  }

  void getArchitectureBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getArchitectureBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/ArchitectureBlocks('AB-01')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
      writeln("No specific ID provided, returning all Architecture blocks");

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
    writeln("Searching for Architecture block with ID: ", rawId);
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
    auto response = match.toJson.set("@odata.context", "$metadata#ArchitectureBlocks/$entity");
    writeln("Response JSON for single Architecture block: ", response);
    res.writeJsonBody(response);
  }

}

class ArchitectureODataController : ODataController {
  protected ManageArchitectureUseCase _useCase;

  this(ManageArchitectureUseCase useCase) {
    this._useCase = useCase;
  }

  /// GET /EntitySet mit optionaler $expand Option
  Json getEntitySet(string entitySetName, string expand = "") {
    if (entitySetName != "ArchitectureBlocks") {
      return Json.emptyArray;
    }

    auto blocks = _useCase.listBlocks();
    return blocks.map!(block => block.toJson).array.toJson;
  }

  /// GET /EntitySet('1001') (Einzel-Entität abfragen)
  Json getEntity(string entitySetName, string id, string expand = "") {
    if (entitySetName != "ArchitectureBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.getBlock(id);
    return block.isNull ? Json.emptyObject : block.toJson;
  }

  /// POST /EntitySet (Entität erstellen)
  Json createEntity(string entitySetName, Json payload) {
    if (entitySetName != "ArchitectureBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.createBlock(payload);
    return block.toJson;
  }

  /// PATCH /EntitySet('1001') (Entität teilweise aktualisieren)
  Json updateEntity(string entitySetName, string id, Json payload) {
    if (entitySetName != "ArchitectureBlocks") {
      return Json.emptyObject;
    }

    auto block = _useCase.updateBlock(payload.set("ID", id));
    return block.isNull ? Json.emptyObject : block.toJson;
  }

  /// DELETE /EntitySet('1001') (Entität löschen)
  bool deleteEntity(string entitySetName, string id) {
    if (entitySetName != "ArchitectureBlocks") {
      return false;
    }

    _useCase.deleteBlock(id);
    return true;
  }

  BatchResponseItem response(BatchRequestItem item) {
    // Implement the logic to handle the batch request for ArchitectureBlocks
    // This is a placeholder implementation and should be replaced with actual logic
    auto response = BatchResponseItem(item.id, 200, Json.emptyObject);

    switch (item.method) {
    case "GET":
      // Handle GET request
      auto urlParts = item.url.split("?");
      if (urlParts.length > 0) {
        auto path = urlParts[0];
        auto query = urlParts.length > 1 ? urlParts[1] : "";

        if (path == "ArchitectureBlocks") {
          response.body = Json.emptyObject
            .set("@odata.context", "$metadata#ArchitectureBlocks")
            .set("value", _useCase.listBlocks().map!(block => block.toJson).array.toJson); // Handle GET request for ArchitectureBlocks entity set
        }
      }
      break;
    case "POST":
      // Handle POST request
      break;
    case "PATCH":
      // Handle PATCH request
      break;
    case "DELETE":
      // Handle DELETE request
      break;
    default:
      // Handle unknown method
      break;
    }

    return response;
  }
}
