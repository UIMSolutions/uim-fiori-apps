module uim.fiori_blocks.presentation.odata.interfaces;

import uim.fiori_blocks;

@safe:

class InterfaceOdataController : OdataController {
  protected ManageInterfaceUseCase useCase;

  this(ManageInterfaceUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/odata/v4/InterfaceBlocks*", &getInterfaceBlockByIdOrAll);
    // router.get("/api/v1/interfaces", &handleList);
    // router.get("/api/v1/interfaces/*", &handleGet);
    // router.put("/api/v1/interfaces/*", &handleUpdate);
    // router.delete_("/api/v1/interfaces/*", &handleDelete);
  }

  void getInterfaceBlockById(HTTPServerRequest req, HTTPServerResponse res) {
    import std.algorithm : find;
    import std.array : array;
    import std.string : strip, chomp, chompPrefix;

    string rawId = req.params["id"];
    // Entfernt OData ' Encodings falls vorhanden
    if (rawId.startsWith("'") && rawId.endsWith("'")) {
      rawId = rawId[1 .. $ - 1];
    }

    auto interfaces = new InterfaceRepository;
    auto match = interfaces.findById(rawId);

    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    if (match.ID !is null) {
      // Einzelergebnis in OData v4 ist direkt das Objekt (kein "value": [] Wrapper!)
      res.writeJsonBody(match.toJson);
    } else {
      res.statusCode = HTTPStatus.notFound;
      res.writeBody("Entity not found");
    }
  }

  void getInterfaceBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getInterfaceBlocks called");
    string filterQuery = req.params.get("$filter", "");

    auto interfaces = new InterfaceRepository;
    InterfaceBlock[] blocks = interfaces.findAll();

    res.headers["OData-Version"] = "4.0";
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    auto response = Json.emptyObject.set("value", blocks.map!(b => b.toJson).array.toJson);
    return res.writeODataJson(response, HTTPStatus.ok);
  }

  void getInterfaceBlockByIdOrAll(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("getInterfaceBlockByIdOrAll called");
    writeln("Request URL: ", req.requestURL);
    res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    res.headers["OData-Version"] = "4.0";

    string requestPath = req.requestURL; // z.B. /odata/v4/InterfaceBlocks('IF-02')

    auto startIdx = requestPath.indexOf("(");
    auto endIdx = requestPath.lastIndexOf(")");

    // 1. Wenn keine Klammern da sind -> Alle Schnittstellen zurückgeben (Collection)
    if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
      writeln("No specific ID provided, returning all Interface blocks");

      auto interfaces = new InterfaceRepository;
      auto filtered = interfaces.findAll
        .filter!(b => b.Type == "Interface")
        .map!(b => b.toJson)
        .array
        .toJson;
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
    writeln("Searching for Interface block with ID: ", rawId);
    auto interfaces = new InterfaceRepository;
    auto match = interfaces.findAll.filter!(b => b.ID == rawId).array;

    if (!match.empty) {
      // Einzel-Objekt in OData v4 wird OHNE {"value": [...]} Wrapper gesendet!
      res.headers["OData-Version"] = "4.0";
      res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
      auto response = match[0].toJson.set("@odata.context", "$metadata#InterfaceBlocks/$entity");
      writeln("Response JSON for single Interface block: ", response);
      res.writeJsonBody(response);
    } else {
      res.headers["OData-Version"] = "4.0";
      res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
      res.statusCode = HTTPStatus.notFound;
      res.writeJsonBody(["error": "Entity not found"]);
    }
  }
}
