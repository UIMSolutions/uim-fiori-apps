module uim.fiori.odata.router;

import uim.fiori;

@safe:

class ODataRouter {
    public string cachedMetadata;
    protected ODataController[string] controllers;

    void registerController(string entitySet, ODataController controller) {
        controllers[entitySet] = controller;
    }

    void registerRoutes(URLRouter router, string basePath = "/api/v4") {
        router.get(basePath ~ "/$metadata", &handleMetadata);
        router.post(basePath ~ "/$batch", &handleBatch);
        router.get(basePath ~ "/:entitySet", &handleGetEntitySet);
        router.post(basePath ~ "/:entitySet", &handlePostEntity);
    }

    protected BatchResponseItem executeBatchItem(BatchRequestItem item) {
        writeln("ODataRouter:Executing batch item: ", item.method, " ", item.entitySet, " with id: ", item
                .id);

        BatchResponseItem response;
        response.id = item.id;

        auto pController = item.entitySet in controllers;
        if (!pController) {
            response.status = 404;
            response.body = Json([
                "error": Json([
                    "message": Json("Controller not found for " ~ item.entitySet)
                ])
            ]);
            return response;
        }

        auto controller = *pController;
        string method = item.method.toUpper();

        if (method == "POST") {
            try {
                Json created = controller.createEntity(item.entitySet, item.body);
                response.status = 201;
                response.headers["content-type"] = "application/json;odata.metadata=minimal";
                if ("Id" in created) {
                    response.headers["location"] = item.entitySet ~ "('" ~ created["ID"].get!string ~ "')";
                }
                response.body = created;
            } catch (Exception e) {
                response.status = 400;
                response.body = Json(["error": Json(["message": Json(e.msg)])]);
            }
        } else if (method == "GET") {
            try {
                Json res = controller.getEntitySet(item.entitySet);
                response.status = 200;
                response.headers["content-type"] = "application/json;odata.metadata=minimal";
                response.body = res;
            } catch (Exception e) {
                response.status = 400;
                response.body = Json(["error": Json(["message": Json(e.msg)])]);
            }
        }

        return response;
    }

    protected void handleBatch(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("ODataRouter: Handling OData batch request: ", req.method, " ", req.requestURL);

        string contentType = req.headers.get("Content-Type", "");
        writeln("ODataRouter: Batch request Content-Type: ", contentType);

        if (contentType.canFind("application/json")) {
            handleJsonBatch(req, res);
        } else if (contentType.canFind("multipart/mixed")) {
            handleMultipartBatch(req, res, contentType);
        } else {
            res.statusCode = 415; // Unsupported Media Type
            res.headers["OData-Version"] = "4.0";
            res.writeBody(
                "Unsupported $batch Content-Type. Expected application/json or multipart/mixed.");
        }
    }

    /// Handler für OData v4 JSON Batch (application/json)
    protected void handleJsonBatch(HTTPServerRequest req, HTTPServerResponse res) {
        Json jsonBody = !req.json.isUndefined ? req.json : Json(null);

        // BatchRequestItem[] requests = parseJsonBatch(jsonBody);
        // BatchResponseItem[] responses;
        // foreach (item; requests) { responses ~= executeBatchItem(item); }

        // Beispiel-Payload für JSON Batch Response
        Json rootRes = Json.emptyObject;
        Json arr = Json.emptyArray;

        Json headers = Json.emptyObject
            .set("content-type", "application/json;odata.metadata=minimal;charset=utf-8")
            .set("odata-version", "4.0");

        Json subRes = Json.emptyObject
            .set("id", "1")
            .set("status", 200)
            .set("headers", headers)
            .set("body", controllers["Addresses"].getEntitiesJson());

        arr.appendArrayElement(subRes);
        rootRes["responses"] = arr;

        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.headers["OData-Version"] = "4.0";
        res.writeJsonBody(rootRes);
    }

    /// Handler für klassisches OData v4 Multipart Batch (multipart/mixed)
    protected void handleMultipartBatch(HTTPServerRequest req, HTTPServerResponse res, string contentType) {
        writeln("ODataRouter: Handling multipart/mixed batch request with Content-Type: ", contentType);

        // 1. Request Body als UTF-8 lesen
        string reqBody = req.bodyReader.readAllUTF8();

        // Boundary aus dem Incoming-Header ermitteln
        string incomingBoundary = "";
        if (contentType.canFind("boundary=")) {
            auto parts = contentType.split("boundary=");
            if (parts.length > 1) {
                incomingBoundary = parts[1].strip();
            }
            writeln("ODataRouter: Incoming batch boundary: ", incomingBoundary);
        }
        string resBoundary = "batchresponse_" ~ (incomingBoundary.length > 0 ? incomingBoundary
                : "12345");

        // 3. Content-ID aus dem Request extrahieren (falls von UI5 mitgeschickt)
        string contentId = "1";
        if (reqBody.canFind("Content-ID:")) {
            writeln("ODataRouter: Found Content-ID in request body, extracting...");

            auto cidIdx = reqBody.indexOf("Content-ID:");
            if (cidIdx != -1) {
                auto rest = reqBody[cidIdx + 11 .. $];
                ptrdiff_t endLine = rest.indexOf("\r\n");
                if (endLine == -1)
                    endLine = rest.indexOf("\n");
                if (endLine != -1) {
                    import std.string : strip;

                    contentId = rest[0 .. endLine].strip();
                }
            }
        }
        writeln("ODataRouter: Extracted Content-ID from request: ", contentId);

        res.statusCode = 200;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "multipart/mixed; boundary=" ~ resBoundary;

        // Aufbau des Multipart-Antwort-Bodys mit allen Pflicht-Headern (incl. Content-ID)
        string body = "--" ~ resBoundary ~ "\r\n";
        body ~= "Content-Type: application/http\r\n";
        body ~= "Content-Transfer-Encoding: binary\r\n";
        body ~= "Content-ID: 1\r\n\r\n"; // Wichtig für SAPUI5 Zuordnung

        body ~= "HTTP/1.1 200 OK\r\n";
        body ~= "Content-Type: application/json;odata.metadata=minimal;charset=utf-8\r\n";
        body ~= "OData-Version: 4.0\r\n\r\n";

        // Daten als JSON-String einbetten
        body ~= controllers["Addresses"].getEntitiesJson().toString() ~ "\r\n";
        body ~= "--" ~ resBoundary ~ "--\r\n";

        res.writeBody(body);
    }

    protected void handleGetEntitySet(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("ODataRouter:Handling GET request for entity set: ", req.method, " ", req
                .requestURL);

        string entitySet = req.params["entitySet"];
        string expand = req.query.get("$expand", "");

        if (entitySet in controllers) {
            res.contentType = "application/json;odata.metadata=minimal";
            res.writeJsonBody(controllers[entitySet].getEntitySet(entitySet, expand));
        } else {
            res.statusCode = 404;
        }
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    }

    protected void handlePostEntity(HTTPServerRequest req, HTTPServerResponse res) {
        string entitySet = req.params["entitySet"];
        if (entitySet in controllers) {
            Json created = controllers[entitySet].createEntity(entitySet, req.json);
            res.statusCode = 201;
            res.contentType = "application/json;odata.metadata=minimal";
            res.writeJsonBody(created);
        } else {
            res.statusCode = 404;
        }
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    }

    protected void handleMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        // Der Content-Type FÜR OData v4 Metadaten MUSS application/xml sein
        res.contentType = "application/xml";
        res.headers["OData-Version"] = "4.0";

        res.writeBody(getMetadataXML());
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
    }

    protected string getMetadataXML() {
        return cachedMetadata;
        // return cachedMetadata.length > 0 ? cachedMetadata : (cachedMetadata = generateEdmx!("ODataService", Address)());
    }
    //         return `<?xml version="1.0" encoding="utf-8"?>
    // <edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
    //     <edmx:DataServices>
    //         <Schema Namespace="ODataService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
    //             <EntityType Name="Address">
    //                 <Key>
    //                     <PropertyRef Name="ID" />
    //                 </Key>
    //                 <Property Name="ID" Type="Edm.String" Nullable="false" />
    //                 <Property Name="FirstName" Type="Edm.String" />
    //                 <Property Name="LastName" Type="Edm.String" />
    //                 <Property Name="Street" Type="Edm.String" />
    //                 <Property Name="City" Type="Edm.String" />
    //                 <Property Name="PostalCode" Type="Edm.String" />
    //                 <Property Name="Country" Type="Edm.String" />
    //             </EntityType>
    //             <EntityContainer Name="EntityContainer">
    //                 <EntitySet Name="Addresses" EntityType="ODataService.Address" />
    //             </EntityContainer>
    //         </Schema>
    //     </edmx:DataServices>
    // </edmx:Edmx>`;
    //     }
}
