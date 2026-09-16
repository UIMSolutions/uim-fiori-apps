module uim.fiori.materials.adapters.inbound.http.odata_controller;
import std.algorithm.comparison : min;
import std.algorithm.mutation : reverse;
import std.algorithm.searching : canFind;
import std.algorithm.sorting : sort;
import std.conv : to;
import std.string : indexOf,
    join,
    lastIndexOf,
    split,
    startsWith,
    strip,
    toLower;
import vibe.data.json;
import vibe.http.common : HTTPStatus;
import vibe.http.router;
import vibe.http.server;
import uim.fiori.materials.application.material_application_service;
import uim.fiori.materials.domain.entities;
import uim.fiori.materials;

@safe:
class MaterialODataController {
private:
    MaterialApplicationService _service;

public:
    this(MaterialApplicationService service) {
        _service = service;
    }

    void registerRoutes(URLRouter router) {
        router.get("/odata/v4/material-service", &getServiceDocument);
        router.get("/odata/v4/material-service/", &getServiceDocument);
        router.get("/odata/v4/material-service/$metadata", &getMetadata);
        router.post("/odata/v4/material-service/$batch", &getBatch);
        router.get("/odata/v4/material-service/Materials", &getMaterials);
        router.post("/odata/v4/material-service/Materials", &postMaterial);
        router.get("/odata/v4/material-service/MaterialPlans", &getMaterialPlans);
        router.post("/odata/v4/material-service/MaterialPlans", &postMaterialPlan);
        router.get("/odata/v4/material-service/StockEvaluations", &getStockEvaluations);
        router.get("/odata/v4/material-service/Warehouses", &getWarehouses);
        router.get("/odata/v4/material-service/Suppliers", &getSuppliers);
        router.get(
            "/odata/v4/material-service/WarehouseAssignments",
            &getWarehouseAssignments
        );
        router.post(
            "/odata/v4/material-service/WarehouseAssignments",
            &postWarehouseAssignment
        );
    }

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["@odata.context"] = Json("/odata/v4/material-service/$metadata");
        Json values = Json.emptyArray;
        values ~= buildServiceDocumentEntry("Materials");
        values ~= buildServiceDocumentEntry("MaterialPlans");
        values ~= buildServiceDocumentEntry("StockEvaluations");
        values ~= buildServiceDocumentEntry("Warehouses");
        values ~= buildServiceDocumentEntry("WarehouseAssignments");
        payload["value"] = values;
        res.writeODataJson(payload.toString(), HTTPStatus.ok);
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        auto metadata = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="MaterialService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Material">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String" Nullable="true"/>
        <Property Name="TargetStock" Type="Edm.Double" Nullable="false"/>
        <NavigationProperty Name="Assignments" Type="Collection(MaterialService.WarehouseAssignment)"/>
      </EntityType>
      <EntityType Name="MaterialPlan">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="MaterialID" Type="Edm.String" Nullable="false"/>
        <Property Name="PlannedDate" Type="Edm.String" Nullable="false"/>
        <Property Name="PlannedQuantity" Type="Edm.Double" Nullable="false"/>
      </EntityType>
      <EntityType Name="Warehouse">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="Location" Type="Edm.String" Nullable="false"/>
      </EntityType>
      <EntityType Name="WarehouseAssignment">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="MaterialID" Type="Edm.String" Nullable="false"/>
        <Property Name="WarehouseID" Type="Edm.String" Nullable="false"/>
        <NavigationProperty Name="Warehouse" Type="MaterialService.Warehouse" Nullable="true"/>
      </EntityType>
      <EntityType Name="StockEvaluation">
        <Key><PropertyRef Name="MaterialID"/></Key>
        <Property Name="MaterialID" Type="Edm.String" Nullable="false"/>
        <Property Name="MaterialName" Type="Edm.String" Nullable="false"/>
        <Property Name="OnHand" Type="Edm.Double" Nullable="false"/>
        <Property Name="Reserved" Type="Edm.Double" Nullable="false"/>
        <Property Name="Available" Type="Edm.Double" Nullable="false"/>
        <Property Name="TargetStock" Type="Edm.Double" Nullable="false"/>
        <Property Name="Status" Type="Edm.String" Nullable="false"/>
      </EntityType>
      <EntityType Name="MaterialAssignment">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="MaterialID" Type="Edm.String" Nullable="false"/>
        <Property Name="WarehouseID" Type="Edm.String" Nullable="false"/>
        <NavigationProperty Name="Warehouse" Type="MaterialService.Warehouse" Nullable="true"/>
      </EntityType>
      <EntityType Name="Supplier">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="ContactInfo" Type="Edm.String" Nullable="true"/>
        <Property Name="Description" Type="Edm.String" Nullable="true"/>
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Materials" EntityType="MaterialService.Material">
          <NavigationPropertyBinding Path="Assignments" Target="WarehouseAssignments"/>
        </EntitySet>
        <EntitySet Name="MaterialPlans" EntityType="MaterialService.MaterialPlan"/>
        <EntitySet Name="StockEvaluations" EntityType="MaterialService.StockEvaluation"/>
        <EntitySet Name="Warehouses" EntityType="MaterialService.Warehouse"/>
        <EntitySet Name="WarehouseAssignments" EntityType="MaterialService.WarehouseAssignment">
          <NavigationPropertyBinding Path="Warehouse" Target="Warehouses"/>
        </EntitySet>
        <EntitySet Name="MaterialAssignments" EntityType="MaterialService.MaterialAssignment">
          <NavigationPropertyBinding Path="Warehouse" Target="Warehouses"/>
          <NavigationPropertyBinding Path="Material" Target="Materials"/>
        </EntitySet>
        <EntitySet Name="Suppliers" EntityType="MaterialService.Supplier"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
        res.writeBody(metadata, cast(int)HTTPStatus.ok, "application/xml");
    }

    void getBatch(HTTPServerRequest req, HTTPServerResponse res) {
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

    protected void handleJsonBatch(HTTPServerRequest req, HTTPServerResponse res) {
        Json jsonBody = !req.json.isUndefined ? req.json : Json(null);
        writeln("ODataRouter: Handling JSON batch request with body: ", jsonBody);
        // BatchRequestItem[] requests = parseJsonBatch(jsonBody);
        // BatchResponseItem[] responses;
        // foreach (item; requests) { responses ~= executeBatchItem(item); }
        // Beispiel-Payload für JSON Batch Response
        Json rootRes = Json.emptyObject;
        Json arr = Json.emptyArray;
        Json headers = Json.emptyObject
            .set("content-type", "application/json;odata.metadata=minimal;charset=utf-8")
            .set("odata-version", "4.0");
        // Json subRes = Json.emptyObject
        //     .set("id", "1")
        //     .set("status", 200)
        //     .set("headers", headers)
        //     .set("body", controllers["Addresses"].getEntitiesJson());
        // arr.appendArrayElement(subRes);
        // rootRes["responses"] = arr;
        res.contentType = "application/json;odata.metadata=minimal;charset=utf-8";
        res.headers["OData-Version"] = "4.0";
        res.writeJsonBody(rootRes);
    }
    /// Handler für klassisches OData v4 Multipart Batch (multipart/mixed)
    protected void handleMultipartBatch(HTTPServerRequest req, HTTPServerResponse res, string contentType) {
        writeln("ODataRouter: Handling multipart/mixed batch request with Content-Type: ", contentType);
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
        // 1. Request Body als UTF-8 lesen
        string reqBody = req.bodyReader.readAllUTF8();
        writeln("ODataRouter: Incoming multipart/mixed batch request body: \n", reqBody);
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
        string body;
        foreach (singleRequest; reqBody.split("--" ~ incomingBoundary)) {
            if (singleRequest.strip().length == 0)
                continue;
            writeln("ODataRouter: Processing single request part: \n", singleRequest);
            string contentSType = extractContentType(singleRequest);
            string contentEncoding = extractContentEncoding(singleRequest);
            if (singleRequest.canFind("GET ")) {
                body ~= "--" ~ resBoundary ~ "\r\n";
                // Aufbau des Multipart-Antwort-Bodys mit allen Pflicht-Headern (incl. Content-ID)
                if (contentSType.length > 0)
                    body ~= "Content-Type: " ~ contentSType ~ "\r\n";
                if (contentEncoding.length > 0)
                    body ~= "Content-Transfer-Encoding: " ~ contentEncoding ~ "\r\n";
                body ~= "Content-ID: " ~ contentId ~ "\r\n";
                body ~= "\r\n"; // Wichtig für SAPUI5 Zuordnung
                body ~= "HTTP/1.1 200 OK\r\n";
                body ~= "Content-Type: application/json;odata.metadata=minimal;charset=utf-8\r\n";
                body ~= "OData-Version: 4.0\r\n\r\n";
                writeln("ODataRouter: Detected GET request in single request part.");
                if (singleRequest.canFind("GET Materials")) {
                    writeln("ODataRouter: Detected GET /Materials request.");
                    auto materials = _service.listMaterials();
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#Materials(ID,Name,Description,TargetStock)";
                    result["value"] = buildMaterialArray(materials, false, false, [
                        ], []);
                    body ~= result.toPrettyString;
                }
                if (singleRequest.canFind("GET MaterialPlans")) {
                    writeln("ODataRouter: Detected GET /MaterialPlans request.");
                    auto plans = _service.listPlans();
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#MaterialPlans(ID,MaterialID,PlannedQuantity,PlannedDate)";
                    result["value"] = buildMaterialPlanArray(plans);
                    body ~= result.toPrettyString;
                }
                if (singleRequest.canFind("GET Suppliers")) {
                    writeln("ODataRouter: Detected GET /Suppliers request.");
                    auto suppliers = _service.listSuppliers(); // not implemented
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#Suppliers(ID,Name,ContactInfo,Description)";
                    result["value"] = buildSupplierArray(suppliers);
                    body ~= result.toPrettyString;
                }
                if (singleRequest.canFind("GET WarehouseAssignments")) {
                    writeln("ODataRouter: Detected GET /WarehouseAssignments request.");
                    auto assignments = _service.listAssignments();
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#WarehouseAssignments(ID,MaterialID,WarehouseID)";
                    result["value"] = buildWarehouseAssignmentArray(assignments);
                    body ~= result.toPrettyString;
                }
                if (singleRequest.canFind("GET Warehouses")) {
                    writeln("ODataRouter: Detected GET /Warehouses request.");
                    auto warehouses = _service.listWarehouses();
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#Warehouses(ID,Name,Location)";
                    result["value"] = buildWarehouseArray(warehouses);
                    body ~= result.toPrettyString;
                }
                if (singleRequest.canFind("GET StockEvaluations")) {
                    writeln("ODataRouter: Detected GET /StockEvaluations request.");
                    auto evaluations = _service.listStockEvaluations();
                    Json result = Json.emptyObject;
                    result["@odata.context"] = "$metadata#StockEvaluations(ID,MaterialID,OnHand,Reserved,Available,TargetStock,Status)";
                    result["value"] = buildStockEvaluationArray(evaluations);
                    body ~= result.toPrettyString;
                }
            }
            if (singleRequest.canFind("POST ")) {
                writeln("ODataRouter: Detected POST request.");
                body ~= "--" ~ resBoundary ~ "\r\n";
                // Aufbau des Multipart-Antwort-Bodys mit allen Pflicht-Headern (incl. Content-ID)
                if (contentSType.length > 0)
                    body ~= "Content-Type: " ~ contentSType ~ "\r\n";
                if (contentEncoding.length > 0)
                    body ~= "Content-Transfer-Encoding: " ~ contentEncoding ~ "\r\n";
                body ~= "Content-ID: 1\r\n";
                body ~= "\r\n"; // Wichtig für SAPUI5 Zuordnung
                body ~= "HTTP/1.1 201 Created\r\n";
                body ~= "Content-Type: application/json;odata.metadata=minimal;charset=utf-8\r\n";
                body ~= "OData-Version: 4.0\r\n\r\n";
                if (singleRequest.canFind("POST Materials")) {
                    writeln("ODataRouter: Detected POST /Materials request.");
                    auto newMaterial = extractMaterialFromRequest(singleRequest);
                    auto createdMaterial = _service.createMaterial(newMaterial);
                    body ~= buildMaterial(createdMaterial, false, false, [], []).toPrettyString;
                }
            }
            body ~= "\r\n";
            // Daten als JSON-String einbetten
            // body ~= controllers["Addresses"].getEntitiesJson().toString() ~ "\r\n";
        }
        body ~= "--" ~ resBoundary ~ "--\r\n";
        writeln("Batch Response:\t", body);
        res.writeBody(body);
    }

    void getMaterials(HTTPServerRequest req, HTTPServerResponse res) {
        // void getMaterials(HTTPServerRequest req, HTTPServerResponse res) {
        Material[] materials = applyMaterialQueryOptions(req, _service.listMaterials());
        
        // Wichtig: Context + value Wrapper
        auto payload = ODataResponse!Material(
            "$metadata#Materials(Description,ID,Name,TargetStock)",
            materials
        );

        res.headers["Content-Type"] = "application/json;odata.metadata=minimal";
        res.writeJsonBody(payload);
    }
        // auto page = applyPaging(req, filtered);
        // auto expand = getQueryOption(req, "$expand").toLower();
        // auto includeAssignments = expand.canFind("assignments");
        // auto includeWarehouse = expand.canFind("warehouse");
        // auto assignments = _service.listAssignments();
        // auto warehouses = _service.listWarehouses();
        // writeCollectionResponse(
        //     req,
        //     res,
        //     "Materials(ID,Name,TargetStock,Description)",
        //     buildMaterialArray(
        //         page.values,
        //         includeAssignments,
        //         includeWarehouse,
        //         assignments,
        //         warehouses
        // ),
        // page.hasNext,
        // page.nextSkip
        // );

    void postMaterial(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        Material material;
        material.id = readString(body, "ID");
        material.materialName = readString(body, "Name");
        material.description = readString(body, "Description");
        material.targetStock = readDouble(body, "TargetStock", 0);
        auto created = _service.createMaterial(material);
        writeSingleResponse(
            res,
            buildMaterial(created, false, false, [], []),
            cast(int)HTTPStatus.created
        );
    }

    void getMaterialPlans(HTTPServerRequest req, HTTPServerResponse res) {
        auto filtered = applyPlanQueryOptions(req, _service.listPlans());
        auto page = applyPaging(req, filtered);
        writeCollectionResponse(
            req,
            res,
            "MaterialPlans",
            buildPlanArray(page.values),
            page.hasNext,
            page.nextSkip
        );
    }

    void postMaterialPlan(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        MaterialPlan plan;
        plan.id = readString(body, "ID");
        plan.materialId = readString(body, "MaterialID");
        plan.plannedDate = readString(body, "PlannedDate");
        plan.plannedQuantity = readDouble(body, "PlannedQuantity", 0);
        try {
            auto created = _service.createPlan(plan);
            writeSingleResponse(res, buildPlan(created), cast(int)HTTPStatus.created);
        } catch (Exception ex) {
            writeErrorResponse(res, ex.msg);
        }
    }

    void getStockEvaluations(HTTPServerRequest req, HTTPServerResponse res) {
        auto filtered = applyEvaluationQueryOptions(req, _service.listStockEvaluations());
        auto page = applyPaging(req, filtered);
        writeCollectionResponse(
            req,
            res,
            "StockEvaluations(MaterialID,MaterialName,QuantityOnHand,ReservedQuantity,Available,TargetStock,Status)",
            buildEvaluationArray(page.values),
            page.hasNext,
            page.nextSkip
        );
    }

    void getWarehouses(HTTPServerRequest req, HTTPServerResponse res) {
        auto filtered = applyWarehouseQueryOptions(req, _service.listWarehouses());
        auto page = applyPaging(req, filtered);
        writeCollectionResponse(
            req,
            res,
            "Warehouses",
            buildWarehouseArray(page.values),
            page.hasNext,
            page.nextSkip
        );
    }

    void getSuppliers(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Getting suppliers...");
        auto suppliers = _service.listSuppliers();
        writeln("Retrieved suppliers: ", suppliers.length);

        writeln("Applying supplier query options...");
        auto filtered = applySupplierQueryOptions(req, suppliers);
        writeln("Filtered suppliers: ", filtered.length);

        writeln("Applying paging to filtered suppliers...");
        auto page = applyPaging(req, filtered);
        writeCollectionResponse(
            req,
            res,
            "Suppliers",
            buildSupplierArray(page.values),
            page.hasNext,
            page.nextSkip
        );
    }

    void getWarehouseAssignments(HTTPServerRequest req, HTTPServerResponse res) {
        auto filtered = applyAssignmentQueryOptions(req, _service.listAssignments());
        auto page = applyPaging(req, filtered);
        auto expand = getQueryOption(req, "$expand").toLower();
        auto includeWarehouse = expand.canFind("warehouse");
        auto warehouses = _service.listWarehouses();
        writeCollectionResponse(
            req,
            res,
            "WarehouseAssignments",
            buildAssignmentArray(page.values, includeWarehouse, warehouses),
            page.hasNext,
            page.nextSkip
        );
    }

    void postWarehouseAssignment(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        WarehouseAssignment assignment;
        assignment.id = readString(body, "ID");
        assignment.materialId = readString(body, "MaterialID");
        assignment.warehouseId = readString(body, "WarehouseID");
        try {
            auto created = _service.createAssignment(assignment);
            writeSingleResponse(
                res,
                buildAssignment(created, false, []),
                cast(int)HTTPStatus.created
            );
        } catch (Exception ex) {
            writeErrorResponse(res, ex.msg);
        }
    }

private:
    struct PagingResult(T) {
        T[] values;
        bool hasNext;
        size_t nextSkip;
    }

    string getQueryOption(HTTPServerRequest req, string optionName) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == optionName) {
                return kv.value;
            }
        }
        return "";
    }

    string buildNextLink(HTTPServerRequest req, string entitySetName, size_t nextSkip) {
        string[] queryParams;
        bool skipSeen = false;
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "$skip") {
                queryParams ~= "$skip=" ~ to!string(nextSkip);
                skipSeen = true;
                continue;
            }
            queryParams ~= kv.key ~ "=" ~ kv.value;
        }
        if (!skipSeen) {
            queryParams ~= "$skip=" ~ to!string(nextSkip);
        }
        return "/odata/v4/material-service/" ~ entitySetName ~ "?" ~ queryParams.join("&");
    }

    size_t parseSizeT(string raw, size_t fallback = 0) {
        if (raw.length == 0) {
            return fallback;
        }
        try {
            return to!size_t(raw);
        } catch (Exception) {
            return fallback;
        }
    }

    bool tryParseDouble(string raw, out double value) {
        try {
            value = to!double(raw);
            return true;
        } catch (Exception) {
            value = 0;
            return false;
        }
    }

    string stripOuterParentheses(string expression) {
        auto current = expression.strip();
        while (current.length >= 2 && current[0] == '(' && current[$ - 1] == ')') {
            if (!isWrappedByOuterParentheses(current)) {
                break;
            }
            current = current[1 .. $ - 1].strip();
        }
        return current;
    }

    bool isWrappedByOuterParentheses(string expression) {
        if (expression.length < 2 || expression[0] != '(' || expression[$ - 1] != ')') {
            return false;
        }
        int depth = 0;
        foreach (idx, ch; expression) {
            if (ch == '(') {
                depth++;
            } else if (ch == ')') {
                depth--;
                if (depth == 0 && idx + 1 < expression.length) {
                    return false;
                }
            }
        }
        return depth == 0;
    }

    string[] splitTopLevel(string expression, string delimiter) {
        auto input = expression;
        auto lowerInput = input.toLower();
        auto lowerDelimiter = delimiter.toLower();
        string[] parts;
        size_t segmentStart = 0;
        int depth = 0;
        size_t i = 0;
        while (i < input.length) {
            auto ch = input[i];
            if (ch == '(') {
                depth++;
            } else if (ch == ')' && depth > 0) {
                depth--;
            }
            if (depth == 0 && i + lowerDelimiter.length <= input.length) {
                if (lowerInput[i .. i + lowerDelimiter.length] == lowerDelimiter) {
                    parts ~= input[segmentStart .. i].strip();
                    i += lowerDelimiter.length;
                    segmentStart = i;
                    continue;
                }
            }
            i++;
        }
        parts ~= input[segmentStart .. $].strip();
        return parts;
    }

    bool parseContainsCall(string atom, out string field, out string needle) {
        auto lowered = atom.toLower();
        if (!lowered.startsWith("contains(")) {
            return false;
        }
        auto openPos = atom.indexOf("(");
        auto closePos = atom.lastIndexOf(")");
        if (openPos < 0 || closePos <= openPos) {
            return false;
        }
        auto body = atom[openPos + 1 .. closePos];
        auto parts = splitTopLevel(body, ",");
        if (parts.length != 2) {
            return false;
        }
        field = parts[0].strip().toLower();
        needle = unquote(parts[1]).toLower();
        return true;
    }

    bool tryParseComparison(
        string atom,
        out string field,
        out string operation,
        out string value
    ) {
        auto lowered = atom.toLower();
        string[] operators = [" eq ", " ne ", " gt ", " ge ", " lt ", " le "];
        foreach (op; operators) {
            auto pos = lowered.indexOf(op);
            if (pos < 0) {
                continue;
            }
            field = atom[0 .. pos].strip().toLower();
            operation = op.strip();
            value = unquote(atom[pos + op.length .. $]);
            return true;
        }
        return false;
    }

    bool matchesFilterExpression(
        string expression,
        bool delegate(string atom) @safe evaluateAtomic
    ) {
        auto stripped = stripOuterParentheses(expression);
        if (stripped.length == 0) {
            return true;
        }
        auto orParts = splitTopLevel(stripped, " or ");
        foreach (orPart; orParts) {
            bool andMatch = true;
            auto andParts = splitTopLevel(orPart, " and ");
            foreach (andPart; andParts) {
                auto atom = stripOuterParentheses(andPart);
                if (atom.length == 0) {
                    continue;
                }
                if (!evaluateAtomic(atom)) {
                    andMatch = false;
                    break;
                }
            }
            if (andMatch) {
                return true;
            }
        }
        return false;
    }

    Material[] applyMaterialQueryOptions(HTTPServerRequest req, Material[] input) {
        auto result = applyMaterialFilter(input, getQueryOption(req, "$filter"));
        return applyMaterialOrderBy(result, getQueryOption(req, "$orderby"));
    }

    Material[] applyMaterialFilter(Material[] input, string filter) {
        auto query = filter.strip();
        if (query.length == 0) {
            return input;
        }
        Material[] result;
        foreach (entry; input) {
            if (matchesFilterExpression(query, atom => evaluateMaterialAtomicFilter(entry, atom))) {
                result ~= entry;
            }
        }
        return result;
    }

    bool evaluateMaterialAtomicFilter(Material entry, string atom) {
        string field;
        string needle;
        if (parseContainsCall(atom, field, needle)) {
            if (field == "name") {
                return entry.materialName.toLower().canFind(needle);
            }
            if (field == "description") {
                return entry.description.toLower().canFind(needle);
            }
            return false;
        }
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "id") {
            return compareString(entry.id, operation, value);
        }
        if (field == "name") {
            return compareString(entry.materialName, operation, value);
        }
        if (field == "description") {
            return compareString(entry.description, operation, value);
        }
        if (field == "targetstock") {
            double numeric;
            if (!tryParseDouble(value, numeric)) {
                return false;
            }
            return compareDouble(entry.targetStock, operation, numeric);
        }
        return false;
    }

    Material[] applyMaterialOrderBy(Material[] input, string orderBy) {
        auto parts = splitBySpace(orderBy);
        if (parts.length == 0) {
            return input;
        }
        auto field = parts[0].toLower();
        auto desc = parts.length > 1 && parts[1].toLower() == "desc";
        auto result = input.dup;
        if (field == "id") {
            sort!((a, b) => a.id < b.id)(result);
        } else if (field == "name") {
            sort!((a, b) => a.materialName < b.materialName)(result);
        } else if (field == "targetstock") {
            sort!((a, b) => a.targetStock < b.targetStock)(result);
        }
        if (desc) {
            reverse(result);
        }
        return result;
    }

    MaterialPlan[] applyPlanQueryOptions(HTTPServerRequest req, MaterialPlan[] input) {
        auto query = getQueryOption(req, "$filter").strip();
        MaterialPlan[] filtered;
        if (query.length > 0) {
            foreach (entry; input) {
                if (matchesFilterExpression(query, atom => evaluatePlanAtomicFilter(entry, atom))) {
                    filtered ~= entry;
                }
            }
        } else {
            filtered = input.dup;
        }
        auto result = filtered.dup;
        auto orderBy = splitBySpace(getQueryOption(req, "$orderby"));
        if (orderBy.length > 0) {
            auto field = orderBy[0].toLower();
            auto desc = orderBy.length > 1 && orderBy[1].toLower() == "desc";
            if (field == "planneddate") {
                sort!((a, b) => a.plannedDate < b.plannedDate)(result);
            } else if (field == "plannedquantity") {
                sort!((a, b) => a.plannedQuantity < b.plannedQuantity)(result);
            }
            if (desc) {
                reverse(result);
            }
        }
        return result;
    }

    bool evaluatePlanAtomicFilter(MaterialPlan entry, string atom) {
        string field;
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "id") {
            return compareString(entry.id, operation, value);
        }
        if (field == "materialid") {
            return compareString(entry.materialId, operation, value);
        }
        if (field == "planneddate") {
            return compareString(entry.plannedDate, operation, value);
        }
        if (field == "plannedquantity") {
            double numeric;
            if (!tryParseDouble(value, numeric)) {
                return false;
            }
            return compareDouble(entry.plannedQuantity, operation, numeric);
        }
        return false;
    }

    Warehouse[] applyWarehouseQueryOptions(HTTPServerRequest req, Warehouse[] input) {
        auto query = getQueryOption(req, "$filter").strip();
        Warehouse[] filtered;
        if (query.length > 0) {
            foreach (entry; input) {
                if (matchesFilterExpression(query, atom => evaluateWarehouseAtomicFilter(entry, atom))) {
                    filtered ~= entry;
                }
            }
        } else {
            filtered = input.dup;
        }
        auto result = filtered.dup;
        auto orderBy = splitBySpace(getQueryOption(req, "$orderby"));
        if (orderBy.length > 0) {
            auto field = orderBy[0].toLower();
            auto desc = orderBy.length > 1 && orderBy[1].toLower() == "desc";
            if (field == "name") {
                sort!((a, b) => a.name < b.name)(result);
            } else if (field == "location") {
                sort!((a, b) => a.location < b.location)(result);
            }
            if (desc) {
                reverse(result);
            }
        }
        return result;
    }

    Supplier[] applySupplierQueryOptions(HTTPServerRequest req, Supplier[] input) {
        auto query = getQueryOption(req, "$filter").strip();
        Supplier[] filtered;
        if (query.length > 0) {
            foreach (entry; input) {
                if (matchesFilterExpression(query, atom => evaluateSupplierAtomicFilter(entry, atom))) {
                    filtered ~= entry;
                }
            }
        } else {
            filtered = input.dup;
        }
        auto result = filtered.dup;
        auto orderBy = splitBySpace(getQueryOption(req, "$orderby"));
        if (orderBy.length > 0) {
            auto field = orderBy[0].toLower();
            auto desc = orderBy.length > 1 && orderBy[1].toLower() == "desc";
            if (field == "name") {
                sort!((a, b) => a.name < b.name)(result);
            } 
            if (desc) {
                reverse(result);
            }
        }
        return result;
    }

    bool evaluateWarehouseAtomicFilter(Warehouse entry, string atom) {
        string field;
        string needle;
        if (parseContainsCall(atom, field, needle)) {
            if (field == "name") {
                return entry.name.toLower().canFind(needle);
            }
            if (field == "location") {
                return entry.location.toLower().canFind(needle);
            }
            return false;
        }
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "id") {
            return compareString(entry.id, operation, value);
        }
        if (field == "name") {
            return compareString(entry.name, operation, value);
        }
        if (field == "location") {
            return compareString(entry.location, operation, value);
        }
        return false;
    }

    bool evaluateSupplierAtomicFilter(Supplier entry, string atom) {
        string field;
        string needle;
        if (parseContainsCall(atom, field, needle)) {
            if (field == "name") {
                return entry.name.toLower().canFind(needle);
            }
            return false;
        }
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "id") {
            return compareString(entry.id, operation, value);
        }
        if (field == "name") {
            return compareString(entry.name, operation, value);
        }
        return false;
    }

    WarehouseAssignment[] applyAssignmentQueryOptions(
        HTTPServerRequest req,
        WarehouseAssignment[] input
    ) {
        auto filter = getQueryOption(req, "$filter").strip();
        if (filter.length == 0) {
            return input;
        }
        WarehouseAssignment[] filtered;
        foreach (entry; input) {
            if (matchesFilterExpression(filter, atom => evaluateAssignmentAtomicFilter(entry, atom))) {
                filtered ~= entry;
            }
        }
        return filtered;
    }

    bool evaluateAssignmentAtomicFilter(WarehouseAssignment entry, string atom) {
        string field;
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "id") {
            return compareString(entry.id, operation, value);
        }
        if (field == "materialid") {
            return compareString(entry.materialId, operation, value);
        }
        if (field == "warehouseid") {
            return compareString(entry.warehouseId, operation, value);
        }
        return false;
    }

    StockEvaluation[] applyEvaluationQueryOptions(
        HTTPServerRequest req,
        StockEvaluation[] input
    ) {
        auto filter = getQueryOption(req, "$filter").strip();
        StockEvaluation[] filtered;
        if (filter.length > 0) {
            foreach (entry; input) {
                if (matchesFilterExpression(filter, atom => evaluateEvaluationAtomicFilter(entry, atom))) {
                    filtered ~= entry;
                }
            }
        } else {
            filtered = input.dup;
        }
        auto result = filtered.dup;
        auto orderBy = splitBySpace(getQueryOption(req, "$orderby"));
        if (orderBy.length > 0) {
            auto field = orderBy[0].toLower();
            auto desc = orderBy.length > 1 && orderBy[1].toLower() == "desc";
            if (field == "available") {
                sort!((a, b) => a.available < b.available)(result);
            } else if (field == "targetstock") {
                sort!((a, b) => a.targetStock < b.targetStock)(result);
            } else if (field == "status") {
                sort!((a, b) => a.status < b.status)(result);
            }
            if (desc) {
                reverse(result);
            }
        }
        return result;
    }

    bool evaluateEvaluationAtomicFilter(StockEvaluation entry, string atom) {
        string field;
        string needle;
        if (parseContainsCall(atom, field, needle)) {
            if (field == "materialname") {
                return entry.materialName.toLower().canFind(needle);
            }
            if (field == "status") {
                return entry.status.toLower().canFind(needle);
            }
            return false;
        }
        string operation;
        string value;
        if (!tryParseComparison(atom, field, operation, value)) {
            return false;
        }
        if (field == "materialid") {
            return compareString(entry.materialId, operation, value);
        }
        if (field == "materialname") {
            return compareString(entry.materialName, operation, value);
        }
        if (field == "status") {
            return compareString(entry.status, operation, value);
        }
        if (field == "available") {
            double numeric;
            if (!tryParseDouble(value, numeric)) {
                return false;
            }
            return compareDouble(entry.available, operation, numeric);
        }
        if (field == "targetstock") {
            double numeric;
            if (!tryParseDouble(value, numeric)) {
                return false;
            }
            return compareDouble(entry.targetStock, operation, numeric);
        }
        return false;
    }

    PagingResult!T applyPaging(T)(HTTPServerRequest req, T[] input) {
        auto skipValue = parseSizeT(getQueryOption(req, "$skip"), 0);
        auto rawTop = getQueryOption(req, "$top").strip();
        auto start = min(skipValue, input.length);
        auto end = input.length;
        bool hasNext = false;
        if (rawTop.length > 0) {
            auto topValue = parseSizeT(rawTop, input.length);
            end = min(start + topValue, input.length);
            hasNext = end < input.length;
        }
        if (start >= end) {
            return PagingResult!T([], false, end);
        }
        return PagingResult!T(input[start .. end].dup, hasNext, end);
    }

    Json buildServiceDocumentEntry(string entitySetName) {
        Json entry = Json.emptyObject;
        entry["name"] = Json(entitySetName);
        entry["kind"] = Json("EntitySet");
        entry["url"] = Json(entitySetName);
        return entry;
    }

    void writeCollectionResponse(
        HTTPServerRequest req,
        HTTPServerResponse res,
        string entitySetName,
        Json valueArray,
        bool hasNext,
        size_t nextSkip
    ) {
        Json response = Json.emptyObject;
        response["@odata.context"] = Json("$metadata#" ~ entitySetName);
        if (hasNext) {
            response["@odata.nextLink"] = Json(buildNextLink(req, entitySetName, nextSkip));
        }
        response["value"] = valueArray;
        res.writeODataJson(response, HTTPStatus.ok);
    }

    void writeSingleResponse(HTTPServerResponse res, Json entity, int code) {
        res.writeBody(entity.toString(), code, "application/json");
    }

    void writeErrorResponse(HTTPServerResponse res, string message) {
        Json errorBody = Json.emptyObject
            .set("code", "BadRequest")
            .set("message", message);
        Json errorRoot = Json.emptyObject
            .set("error", errorBody);
        res.writeJsonBody(
            errorRoot.toString(),
            HTTPStatus.badRequest
        );
    }

    string readString(Json payload, string key, string fallback = "") {
        if (key in payload) {
            return payload[key].to!string;
        }
        return fallback;
    }

    double readDouble(Json payload, string key, double fallback = 0) {
        if (key in payload) {
            return payload[key].get!double;
        }
        return fallback;
    }
}
