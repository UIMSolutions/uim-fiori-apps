/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.batch;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class BatchOdataController : OdataController {

  this() {
  }

  override void registerRoutes(URLRouter router) {
    router.post("/odata/v4/$batch", &handleBaseBlockBatch);
    
  }

  void handleBaseBlockBatch(HTTPServerRequest req, HTTPServerResponse res) {
    auto contentType = req.contentTypeHeader;
    writeln("handleBaseBlockBatch called");
    writeln("--- Request URL: ", req.requestURL);
    writeln("--- Content-Type: ", req.contentTypeHeader);

    // 1. Validation des Content-Type Headers
    if (!contentType.mimeType.startsWith("multipart/mixed")) {
        writeln("--- Invalid Content-Type: ", contentType.mimeType);
      res.writeJsonBody(["error": Json("Batch request must be multipart/mixed")], HTTPStatus
          .badRequest);
      return;
    }

    string mainBoundary;
    if (auto p = "boundary" in contentType.attributes) {
      mainBoundary = *p;
    } else {
      res.writeJsonBody([
        "error": Json("Missing boundary parameter in Content-Type")
      ], HTTPStatus.badRequest);
      return;
    }
    writeln("--- Main boundary: ", mainBoundary);

    // 2. Erzeuge eindeutige Response-Boundary für den Multipart-Return
    string responseBoundary = "batchresponse_" + randomUUID().toString();
    writeln("--- Response boundary: ", responseBoundary);

    res.contentType = "multipart/mixed; boundary=" ~ responseBoundary;
    res.status = HTTPStatus.accepted; // OData v4 Spezifikation verlangt 202 Accepted

    auto outputStream = res.connectOutputStream();

    // 3. Verarbeite die MIME-Parts der Anfrage
    parseFormData(req, (string name, string filename, string contentTypeHeader, InputStream stream) @safe {
      string partContent = stream.readAllUTF8();
      string subResponse = processSingleBaseBlockRequest(partContent);

      // Schreibe Sub-Response im HTTP-MIME-Format heraus
      outputStream.write("--" ~ responseBoundary ~ "\r\n");
      outputStream.write("Content-Type: application/http\r\n");
      outputStream.write("Content-Transfer-Encoding: binary\r\n\r\n");
      outputStream.write(subResponse);
      outputStream.write("\r\n");
    });

    // Multipart-Abschluss
    outputStream.write("--" ~ responseBoundary ~ "--\r\n");
    outputStream.flush();
  }

  /// Parst einen einzelnen Sub-Request innerhalb des Batch-Payloads
  private string processSingleBaseBlockRequest(string rawHttp) @safe {
    auto lines = rawHttp.splitLines();
    if (lines.length == 0)
      return "";

    // Erste Zeile auslesen: z.B. "PATCH /odata/v4/BaseBlocks('123') HTTP/1.1"
    auto reqParts = lines[0].strip().split(" ");
    if (reqParts.length < 2)
      return "";

    string method = reqParts[0];
    string path = reqParts[1];

    // Isolieren des JSON-Bodys (nach Leerzeile \r\n\r\n)
    string body = "";
    ptrdiff_t bodyIndex = rawHttp.indexOf("\r\n\r\n");
    if (bodyIndex != -1) {
      body = rawHttp[bodyIndex + 4 .. $].strip();
    }

    int statusCode = 200;
    Json responseJson = Json.emptyObject;

    // CRUD-Verzweigung für BaseBlock
    try {
      if (method == "PATCH" || method == "PUT") {
        // Deserialisieren & Verarbeiten
        Json payloadJson = parseJsonString(body);
        BaseBlock block = blockFromJson(payloadJson);

        // TODO: Aufruf deiner Repository-/Persistenz-Logik
        // updateBaseBlock(block);

        responseJson = block.toJson();
        statusCode = HTTPStatus.ok; // 200 OK
      } else if (method == "DELETE") {
        // TODO: deleteBaseBlock(extractIdFromPath(path));
        statusCode = HTTPStatus.noContent; // 204 No Content
      } else if (method == "GET") {
        // TODO: BaseBlock block = getBaseBlock(extractIdFromPath(path));
        // responseJson = block.toJson();
        statusCode = HTTPStatus.ok;
      } else if (method == "POST") {
        Json payloadJson = parseJsonString(body);
        BaseBlock block = blockFromJson(payloadJson);

        // TODO: createBaseBlock(block);
        responseJson = block.toJson();
        statusCode = HTTPStatus.created; // 201 Created
      }
    } catch (Exception e) {
      statusCode = HTTPStatus.badRequest;
      responseJson = Json.emptyObject.set("error", Json(["message": Json(e.msg)]));
    }

    // HTTP Sub-Response zusammensetzen
    string httpResponse = "HTTP/1.1 " ~ statusCode.to!string ~ " OK\r\n";
    httpResponse ~= "Content-Type: application/json;odata.metadata=minimal\r\n";
    httpResponse ~= "OData-Version: 4.0\r\n\r\n";

    if (statusCode != HTTPStatus.noContent) {
      httpResponse ~= responseJson.toString();
    }

    return httpResponse;
  }

  /// Hilfsfunktion zur Erzeugung einer BaseBlock Entität aus OData JSON
  private BaseBlock blockFromJson(Json json) @safe {
    BaseBlock block;

    if ("ID" in json)
      block.ID = json["ID"].get!string;
    if ("Name" in json)
      block.Name = json["Name"].get!string;
    if ("Responsible" in json)
      block.Responsible = json["Responsible"].get!string;
    if ("Version" in json)
      block.Version = json["Version"].get!string;
    if ("Date" in json)
      block.Date = json["Date"].get!string;
    if ("Description" in json)
      block.Description = json["Description"].get!string;

    if (auto addInfo = "AdditionalInformation" in json) {
      if (addInfo.type == Json.Type.array) {
        block.AdditionalInformation = addInfo.get!(Json[])
          .map!(i => i.get!string)
          .array;
      }
    }

    return block;
  }
}
