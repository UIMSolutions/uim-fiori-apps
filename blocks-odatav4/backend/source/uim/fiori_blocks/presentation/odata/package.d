/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata;

/// OData v4 endpoints & $metadata generation for SAP Fiori.
public:
  import uim.fiori_blocks.presentation.odata.batch;
  import uim.fiori_blocks.presentation.odata.edm;
  import uim.fiori_blocks.presentation.odata.errors;
  import uim.fiori_blocks.presentation.odata.parser;
  import uim.fiori_blocks.presentation.odata.routes;
  import uim.fiori_blocks.presentation.odata.service;
  import uim.fiori_blocks.presentation.odata.url;

///
unittest {
  // end-to-end through all layers with in-memory storage
  import vibe.data.json : Json, parseJsonString;
  import uim.fiori_blocks.composition;
  import uim.fiori_blocks.infrastructure.configuration;

  AppConfig config;
  config.logLevel = "error";
  auto service = new ODataService(bootstrap(config).catalog);

  ODataResult get(string url) {
    ODataRequest r;
    splitServiceUrl(url, service.serviceRoot, r.path, r.query);
    return service.handle(r);
  }

  ODataResult send(string method, string url, Json body = Json.undefined) {
    ODataRequest r;
    r.method = method;
    r.body = body;
    splitServiceUrl(url, service.serviceRoot, r.path, r.query);
    return service.handle(r);
  }

  // metadata & service document
  assert(service.metadata.canFindText(`<EntitySet Name="ArchitectureBlocks" EntityType="EAModel.ArchitectureBlock"/>`));
  assert(service.metadata.canFindText(`<Property Name="DependsOn" Type="Collection(EAModel.Dependency)" Nullable="false"/>`));
  assert(get("/odata/v4/").json["value"].length == 5);

  // query options
  auto list = get("/odata/v4/Users?$filter=Active%20eq%20true&$orderby=Username%20desc&$count=true&$select=Username");
  assert(list.status == 200 && list.json["@odata.count"].get!long == 2);
  assert(list.json["value"][0]["Username"].get!string == "editor" && "Email" !in list.json["value"][0]);
  assert(get("/odata/v4/Users/$count?$filter=Role eq 'Viewer'").text == "1");

  // CRUD
  auto created = send("POST", "BaseBlocks", Json(["Name": Json("Created")]));
  assert(created.status == 201 && created.json["ID"].get!string == "BB-03");
  assert(created.headers["Location"] == "/odata/v4/BaseBlocks('BB-03')");
  assert(send("PATCH", "BaseBlocks('BB-03')", Json(["Version": Json("2.0")])).json["Name"].get!string == "Created");
  assert(get("BaseBlocks('BB-03')/Version").json["value"].get!string == "2.0");
  assert(send("DELETE", "BaseBlocks('BB-03')").status == 204);
  assert(get("BaseBlocks('BB-03')").status == 404);

  // errors
  assert(get("Nothing").status == 404);
  assert(send("POST", "BaseBlocks", Json(["Name": Json("")])).status == 400);
  assert(send("POST", "BaseBlocks", Json(["ID": Json("BB-01"), "Name": Json("x")])).status == 409);
  assert(get("Users?$filter=Name eq").status == 400);

  // multipart batch with a failing changeset -> rolled back
  enum failing = "--b\r\nContent-Type: multipart/mixed; boundary=c\r\n\r\n"
    ~ "--c\r\nContent-Type: application/http\r\nContent-ID: 1\r\n\r\nPOST InterfaceBlocks HTTP/1.1\r\nContent-Type: application/json\r\n\r\n{\"Name\":\"Tx\"}\r\n"
    ~ "--c\r\nContent-Type: application/http\r\nContent-ID: 2\r\n\r\nDELETE InterfaceBlocks('IF-99') HTTP/1.1\r\n\r\n\r\n"
    ~ "--c--\r\n--b--\r\n";
  auto failed = processMultipartBatch(service, "multipart/mixed; boundary=b", failing);
  assert(failed.text.canFindText("HTTP/1.1 404 Not Found"));
  assert(service.catalog["InterfaceBlocks"].count == 2);

  // successful changeset with Content-ID reference
  enum ok = "--b\r\nContent-Type: multipart/mixed; boundary=c\r\n\r\n"
    ~ "--c\r\nContent-Type: application/http\r\nContent-ID: 1\r\n\r\nPOST InterfaceBlocks HTTP/1.1\r\nContent-Type: application/json\r\n\r\n{\"Name\":\"Tx\"}\r\n"
    ~ "--c\r\nContent-Type: application/http\r\nContent-ID: 2\r\n\r\nPATCH $1 HTTP/1.1\r\nContent-Type: application/json\r\n\r\n{\"Status\":\"Active\"}\r\n"
    ~ "--c--\r\n"
    ~ "--b\r\nContent-Type: application/http\r\n\r\nGET InterfaceBlocks?$filter=Status%20eq%20'Active' HTTP/1.1\r\n\r\n\r\n"
    ~ "--b--\r\n";
  auto done = processMultipartBatch(service, "multipart/mixed; boundary=b", ok);
  assert(done.text.canFindText("HTTP/1.1 201 Created") && done.text.canFindText("HTTP/1.1 200 OK"));
  assert(service.catalog["InterfaceBlocks"].get("IF-03")["Status"].get!string == "Active");

  // JSON batch
  auto json = processJsonBatch(service, parseJsonString(`{"requests":[
    {"id":"r1","method":"GET","url":"Users('USR-001')"},
    {"id":"r2","method":"POST","url":"Users","atomicityGroup":"g","body":{"Username":"neo","Role":"Hacker"}}]}`));
  assert(json.json["responses"][0]["status"].get!int == 200);
  assert(json.json["responses"][1]["status"].get!int == 400);
}

private bool canFindText(string haystack, string needle) @safe pure {
  import std.algorithm : canFind;

  return haystack.canFind(needle);
}
