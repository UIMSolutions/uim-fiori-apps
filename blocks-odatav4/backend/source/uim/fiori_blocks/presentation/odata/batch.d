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
     res.writeBody("", HTTPStatus.accepted, res.contentType);
  }
}
//     string path = req.requestURL;
//     writeln("handleBaseBlockBatch called");
//     // writeln("--- Request URL: ", path);
//     // writeln("--- Content-Type: ", req.contentType);

//     writeln("/---------------------------------/");
//     string reqBody = req.bodyReader.readAllUTF8();
//     writeln(reqBody);
//     writeln("/---------------------------------/");
//     foreach (singleRequest; reqBody.split("--")) {
//         if (singleRequest.strip().length == 0)
//             continue;

//         writeln("/---------------------------------/");
//         writeln("--- Single request: ", singleRequest);
//         writeln("/---------------------------------/");

//         auto lines = singleRequest.split("\r\n");
//         writeln("--- Lines: ", lines);

      
//     }

//     // // 1. Validation des Content-Type Headers
//     // if (!contentType.startsWith("multipart/mixed")) {
//     //   writeln("--- Invalid Content-Type: ", contentType);
//     //   res.writeJsonBody(["error": Json("Batch request must be multipart/mixed")], HTTPStatus
//     //       .badRequest);
//     //   return;
//     // }

//     // writeln("--- Extracting main boundary from Content-Type: ", contentType);
//     // string mainBoundary = extractBoundary(contentType);
//     // writeln("--- Main boundary: ", mainBoundary);
//     // if (mainBoundary.length == 0) {
//     //   res.writeJsonBody([
//     //     "error": Json("Missing boundary parameter in Content-Type")
//     //   ], HTTPStatus.badRequest);
//     //   return;
//     // }

//     // // 2. Erzeuge eindeutige Response-Boundary für den Multipart-Return
//     // string responseBoundary = "batchresponse_" ~ randomUUID().toString();
//     // writeln("--- Response boundary: ", responseBoundary);

//     // res.contentType = "multipart/mixed; boundary=" ~ responseBoundary;

//     // // 3. Verarbeite die MIME-Parts der Anfrage
//     // string requestBody = req.bodyReader.readAllUTF8();
//     // string requestBoundary = "--" ~ mainBoundary;
//     // string multipartResponse;

//     // writeln("--- Starting to process each MIME part of the batch request");
//     // foreach (segment; requestBody.split(requestBoundary)) {
//     //   auto part = segment.strip();
//     //   if (part.length == 0 || part == "--") {
//     //     continue;
//     //   }

//     //   if (part.endsWith("--")) {
//     //     part = part[0 .. $ - 2].strip();
//     //   }

//     //   ptrdiff_t headerSplit = part.indexOf("\r\n\r\n");
//     //   if (headerSplit == -1) {
//     //     continue;
//     //   }

//     //   string partContent = part[headerSplit + 4 .. $].strip();
//     //   if (partContent.length == 0) {
//     //     continue;
//     //   }

//     //   string subResponse = processSingleBaseBlockRequest(partContent);

//     //   multipartResponse ~= "--" ~ responseBoundary ~ "\r\n";
//     //   multipartResponse ~= "Content-Type: application/http\r\n";
//     //   multipartResponse ~= "Content-Transfer-Encoding: binary\r\n\r\n";
//     //   multipartResponse ~= subResponse ~ "\r\n";
//     // }

//     // // Multipart-Abschluss
//     // multipartResponse ~= "--" ~ responseBoundary ~ "--\r\n";
//     // res.writeBody(multipartResponse, cast(int)HTTPStatus.accepted, res.contentType);
//     res.writeBody("", HTTPStatus.accepted, res.contentType);
//   }

//   void handleBaseBlockBatchOld(HTTPServerRequest req, HTTPServerResponse res) {
//     auto contentType = req.contentType;
//     writeln("handleBaseBlockBatch called");
//     writeln("--- Request URL: ", req.requestURL);
//     writeln("--- Content-Type: ", req.contentType);

//     // 1. Validation des Content-Type Headers
//     if (!contentType.startsWith("multipart/mixed")) {
//       writeln("--- Invalid Content-Type: ", contentType);
//       res.writeJsonBody(["error": Json("Batch request must be multipart/mixed")], HTTPStatus
//           .badRequest);
//       return;
//     }

//     writeln("--- Extracting main boundary from Content-Type: ", contentType);
//     string mainBoundary = extractBoundary(contentType);
//     writeln("--- Main boundary: ", mainBoundary);
//     if (mainBoundary.length == 0) {
//       res.writeJsonBody([
//         "error": Json("Missing boundary parameter in Content-Type")
//       ], HTTPStatus.badRequest);
//       return;
//     }

//     // 2. Erzeuge eindeutige Response-Boundary für den Multipart-Return
//     string responseBoundary = "batchresponse_" ~ randomUUID().toString();
//     writeln("--- Response boundary: ", responseBoundary);

//     res.contentType = "multipart/mixed; boundary=" ~ responseBoundary;

//     // 3. Verarbeite die MIME-Parts der Anfrage
//     string requestBody = req.bodyReader.readAllUTF8();
//     string requestBoundary = "--" ~ mainBoundary;
//     string multipartResponse;

//     writeln("--- Starting to process each MIME part of the batch request");
//     foreach (segment; requestBody.split(requestBoundary)) {
//       auto part = segment.strip();
//       if (part.length == 0 || part == "--") {
//         continue;
//       }

//       if (part.endsWith("--")) {
//         part = part[0 .. $ - 2].strip();
//       }

//       ptrdiff_t headerSplit = part.indexOf("\r\n\r\n");
//       if (headerSplit == -1) {
//         continue;
//       }

//       string partContent = part[headerSplit + 4 .. $].strip();
//       if (partContent.length == 0) {
//         continue;
//       }

//       string subResponse = processSingleBaseBlockRequest(partContent);

//       multipartResponse ~= "--" ~ responseBoundary ~ "\r\n";
//       multipartResponse ~= "Content-Type: application/http\r\n";
//       multipartResponse ~= "Content-Transfer-Encoding: binary\r\n\r\n";
//       multipartResponse ~= subResponse ~ "\r\n";
//     }

//     // Multipart-Abschluss
//     multipartResponse ~= "--" ~ responseBoundary ~ "--\r\n";
//     res.writeBody(multipartResponse, cast(int)HTTPStatus.accepted, res.contentType);
//   }

//   /// Parst einen einzelnen Sub-Request innerhalb des Batch-Payloads
//   private string processSingleBaseBlockRequest(string rawHttp) @safe {
//     auto lines = rawHttp.splitLines();
//     if (lines.length == 0)
//       return "";

//     // Erste Zeile auslesen: z.B. "PATCH /odata/v4/BaseBlocks('123') HTTP/1.1"
//     auto reqParts = lines[0].strip().split(" ");
//     if (reqParts.length < 2)
//       return "";

//     string method = reqParts[0];

//     // Isolieren des JSON-Bodys (nach Leerzeile \r\n\r\n)
//     string body = "";
//     ptrdiff_t bodyIndex = rawHttp.indexOf("\r\n\r\n");
//     if (bodyIndex != -1) {
//       body = rawHttp[bodyIndex + 4 .. $].strip();
//     }

//     int statusCode = cast(int)HTTPStatus.ok;
//     Json responseJson = Json.emptyObject;

//     // CRUD-Verzweigung für BaseBlock
//     try {
//       if (method == "PATCH" || method == "PUT") {
//         // Deserialisieren & Verarbeiten
//         Json payloadJson = parseJsonString(body);
//         BaseBlock block = blockFromJson(payloadJson);

//         // TODO: Aufruf deiner Repository-/Persistenz-Logik
//         // updateBaseBlock(block);

//         responseJson = block.toJson();
//         statusCode = cast(int)HTTPStatus.ok; // 200 OK
//       } else if (method == "DELETE") {
//         // TODO: deleteBaseBlock(extractIdFromPath(path));
//         statusCode = cast(int)HTTPStatus.noContent; // 204 No Content
//       } else if (method == "GET") {
//         // TODO: BaseBlock block = getBaseBlock(extractIdFromPath(path));
//         // responseJson = block.toJson();
//         statusCode = cast(int)HTTPStatus.ok;
//       } else if (method == "POST") {
//         Json payloadJson = parseJsonString(body);
//         BaseBlock block = blockFromJson(payloadJson);

//         // TODO: createBaseBlock(block);
//         responseJson = block.toJson();
//         statusCode = cast(int)HTTPStatus.created; // 201 Created
//       }
//     } catch (Exception e) {
//       statusCode = cast(int)HTTPStatus.badRequest;
//       responseJson = Json.emptyObject;
//       responseJson["error"] = Json.emptyObject;
//       responseJson["error"]["message"] = Json(e.msg);
//     }

//     // HTTP Sub-Response zusammensetzen
//     string httpResponse = "HTTP/1.1 " ~ statusCode.to!string ~ " OK\r\n";
//     httpResponse ~= "Content-Type: application/json;odata.metadata=minimal\r\n";
//     httpResponse ~= "OData-Version: 4.0\r\n\r\n";

//     if (statusCode != cast(int)HTTPStatus.noContent) {
//       httpResponse ~= responseJson.toString();
//     }

//     return httpResponse;
//   }

//   private string extractBoundary(string contentType) @safe {
//     foreach (part; contentType.split(";")) {
//       auto token = part.strip();
//       if (!token.startsWith("boundary=")) {
//         continue;
//       }

//       string boundary = token["boundary=".length .. $].strip();
//       if (boundary.length >= 2 && boundary[0] == '"' && boundary[$ - 1] == '"') {
//         boundary = boundary[1 .. $ - 1];
//       }
//       return boundary;
//     }

//     return "";
//   }

//   /// Hilfsfunktion zur Erzeugung einer BaseBlock Entität aus OData JSON
//   private BaseBlock blockFromJson(Json json) @safe {
//     BaseBlock block;

//     if ("ID" in json)
//       block.ID = json["ID"].get!string;
//     if ("Name" in json)
//       block.Name = json["Name"].get!string;
//     if ("Responsible" in json)
//       block.Responsible = json["Responsible"].get!string;
//     if ("Version" in json)
//       block.Version = json["Version"].get!string;
//     if ("Date" in json)
//       block.Date = json["Date"].get!string;
//     if ("Description" in json)
//       block.Description = json["Description"].get!string;

//     if (auto addInfo = "AdditionalInformation" in json) {
//       if (addInfo.type == Json.Type.array) {
//         block.AdditionalInformation = addInfo.get!(Json[])
//           .map!(i => i.get!string)
//           .array;
//       }
//     }

//     return block;
//   }
// }
// // 