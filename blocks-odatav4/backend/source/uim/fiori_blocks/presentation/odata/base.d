/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.base;

import uim.fiori_blocks;
import uim.fiori_blocks.application.usecases.solution;

mixin(ShowModule!());

@safe:
class BaseOdataController : OdataController {
  protected ManageBaseUseCase _useCase;

  this(ManageBaseUseCase useCase) {
    this._useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/odata/v4/BaseBlocks*", &getBaseBlockByIdOrAll);
    router.post("/odata/v4/$batch", &handleBaseBlockBatch);

    // router.get("/api/v1/configs", &handleList);
    // router.get("/api/v1/configs/*", &handleGet);
    // router.put("/api/v1/configs/*", &handleUpdate);
    // router.delete_("/api/v1/configs/*", &handleDelete);
  }

  void getBaseBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getBaseBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/BaseBlocks('SB-01')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
      writeln("No specific ID provided, returning all Base blocks");

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
    writeln("Searching for Base block with ID: ", rawId);
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
    auto response = match.toJson.set("@odata.context", "$metadata#BaseBlocks/$entity");
    writeln("Response JSON for single Base block: ", response);
    res.writeJsonBody(response);
  }
}
