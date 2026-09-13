module uim.fiori.material.adapters.inbound.http.odata_controller;
import std.algorithm.comparison : min;
import std.algorithm.mutation : reverse;
import std.algorithm.searching : canFind;
import std.algorithm.sorting : sort;
import std.conv : to;
import std.string :
    indexOf,
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
import uim.fiori.material.application.material_application_service;
import uim.fiori.material.domain.entities;
import uim.fiori.material;
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
        router.get("/odata/v4/material-service/Materials", &getMaterials);
        router.post("/odata/v4/material-service/Materials", &postMaterial);
        router.get("/odata/v4/material-service/MaterialPlans", &getMaterialPlans);
        router.post("/odata/v4/material-service/MaterialPlans", &postMaterialPlan);
        router.get("/odata/v4/material-service/StockEvaluations", &getStockEvaluations);
        router.get("/odata/v4/material-service/Warehouses", &getWarehouses);
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
        <Property Name="Contact" Type="Edm.String" Nullable="false"/>
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
        res.writeBody(metadata, cast(int) HTTPStatus.ok, "application/xml");
    }

    void getMaterials(HTTPServerRequest req, HTTPServerResponse res) {
        auto filtered = applyMaterialQueryOptions(req, _service.listMaterials());
        auto page = applyPaging(req, filtered);
        auto expand = getQueryOption(req, "$expand").toLower();
        auto includeAssignments = expand.canFind("assignments");
        auto includeWarehouse = expand.canFind("warehouse");
        auto assignments = _service.listAssignments();
        auto warehouses = _service.listWarehouses();
        writeCollectionResponse(
            req,
            res,
            "Materials",
            buildMaterialArray(
                page.values,
                includeAssignments,
                includeWarehouse,
                assignments,
                warehouses
            ),
            page.hasNext,
            page.nextSkip
        );
    }

    void postMaterial(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        Material material;
        material.id = readString(body, "ID");
        material.name = readString(body, "Name");
        material.description = readString(body, "Description");
        material.targetStock = readDouble(body, "TargetStock", 0);
        auto created = _service.createMaterial(material);
        writeSingleResponse(
            res,
            buildMaterial(created, false, false, [], []),
            cast(int) HTTPStatus.created
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
            writeSingleResponse(res, buildPlan(created), cast(int) HTTPStatus.created);
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
            "StockEvaluations",
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
                cast(int) HTTPStatus.created
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
    string unquote(string input) {
        auto value = input.strip();
        if (value.length >= 2 && value[0] == '\'' && value[$ - 1] == '\'') {
            return value[1 .. $ - 1];
        }
        return value;
    }
    string[] splitBySpace(string value) {
        string[] tokens;
        foreach (segment; value.strip().split(" ")) {
            if (segment.strip().length > 0) {
                tokens ~= segment.strip();
            }
        }
        return tokens;
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
    bool compareString(string left, string operation, string right) {
        final switch (operation) {
            case "eq":
                return left == right;
            case "ne":
                return left != right;
            case "gt":
                return left > right;
            case "ge":
                return left >= right;
            case "lt":
                return left < right;
            case "le":
                return left <= right;
        }
    }
    bool compareDouble(double left, string operation, double right) {
        final switch (operation) {
            case "eq":
                return left == right;
            case "ne":
                return left != right;
            case "gt":
                return left > right;
            case "ge":
                return left >= right;
            case "lt":
                return left < right;
            case "le":
                return left <= right;
        }
    }
    bool matchesFilterExpression(
        string expression,
        bool delegate(string atom) evaluateAtomic
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
                return entry.name.toLower().canFind(needle);
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
            return compareString(entry.name, operation, value);
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
            sort!((a, b) => a.name < b.name)(result);
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
    Json buildMaterial(
        Material material,
        bool includeAssignments,
        bool includeWarehouse,
        WarehouseAssignment[] assignments,
        Warehouse[] warehouses
    ) {
        Json item = Json.emptyObject;
        item["ID"] = Json(material.id);
        item["Name"] = Json(material.name);
        item["Description"] = Json(material.description);
        item["TargetStock"] = Json(material.targetStock);
        if (includeAssignments) {
            Json expandedAssignments = Json.emptyArray;
            foreach (assignment; assignments) {
                if (assignment.materialId == material.id) {
                    expandedAssignments ~= buildAssignment(
                        assignment,
                        includeWarehouse,
                        warehouses
                    );
                }
            }
            item["Assignments"] = expandedAssignments;
        }
        return item;
    }
    Json buildPlan(MaterialPlan plan) {
        Json item = Json.emptyObject;
        item["ID"] = Json(plan.id);
        item["MaterialID"] = Json(plan.materialId);
        item["PlannedDate"] = Json(plan.plannedDate);
        item["PlannedQuantity"] = Json(plan.plannedQuantity);
        return item;
    }
    Json buildWarehouse(Warehouse warehouse) {
        Json item = Json.emptyObject;
        item["ID"] = Json(warehouse.id);
        item["Name"] = Json(warehouse.name);
        item["Location"] = Json(warehouse.location);
        return item;
    }
    Json buildAssignment(
        WarehouseAssignment assignment,
        bool includeWarehouse,
        Warehouse[] warehouses
    ) {
        Json item = Json.emptyObject;
        item["ID"] = Json(assignment.id);
        item["MaterialID"] = Json(assignment.materialId);
        item["WarehouseID"] = Json(assignment.warehouseId);
        if (includeWarehouse) {
            foreach (warehouse; warehouses) {
                if (warehouse.id == assignment.warehouseId) {
                    item["Warehouse"] = buildWarehouse(warehouse);
                    break;
                }
            }
        }
        return item;
    }
    Json buildEvaluation(StockEvaluation evaluation) {
        Json item = Json.emptyObject;
        item["MaterialID"] = Json(evaluation.materialId);
        item["MaterialName"] = Json(evaluation.materialName);
        item["OnHand"] = Json(evaluation.onHand);
        item["Reserved"] = Json(evaluation.reserved);
        item["Available"] = Json(evaluation.available);
        item["TargetStock"] = Json(evaluation.targetStock);
        item["Status"] = Json(evaluation.status);
        return item;
    }
    Json buildMaterialArray(
        Material[] entries,
        bool includeAssignments,
        bool includeWarehouse,
        WarehouseAssignment[] assignments,
        Warehouse[] warehouses
    ) {
        Json result = Json.emptyArray;
        foreach (entry; entries) {
            result ~= buildMaterial(
                entry,
                includeAssignments,
                includeWarehouse,
                assignments,
                warehouses
            );
        }
        return result;
    }
    Json buildPlanArray(MaterialPlan[] entries) {
        Json result = Json.emptyArray;
        foreach (entry; entries) {
            result ~= buildPlan(entry);
        }
        return result;
    }
    Json buildWarehouseArray(Warehouse[] entries) {
        Json result = Json.emptyArray;
        foreach (entry; entries) {
            result ~= buildWarehouse(entry);
        }
        return result;
    }
    Json buildAssignmentArray(
        WarehouseAssignment[] entries,
        bool includeWarehouse,
        Warehouse[] warehouses
    ) {
        Json result = Json.emptyArray;
        foreach (entry; entries) {
            result ~= buildAssignment(entry, includeWarehouse, warehouses);
        }
        return result;
    }
    Json buildEvaluationArray(StockEvaluation[] entries) {
        Json result = Json.emptyArray;
        foreach (entry; entries) {
            result ~= buildEvaluation(entry);
        }
        return result;
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
        res.writeODataJson(response.toString(), HTTPStatus.ok);
    }

    void writeSingleResponse(HTTPServerResponse res, Json entity, int code) {
        res.writeBody(entity.toString(), code, "application/json");
    }

    void writeErrorResponse(HTTPServerResponse res, string message) {
        Json errorRoot = Json.emptyObject;
        Json errorBody = Json.emptyObject;
        errorBody["code"] = Json("BadRequest");
        errorBody["message"] = Json(message);
        errorRoot["error"] = errorBody;
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
