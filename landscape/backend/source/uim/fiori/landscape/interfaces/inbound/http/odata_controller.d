module uim.fiori.landscape.interfaces.inbound.http.odata_controller;
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
import uim.fiori.landscape.application.landscape_service;
import uim.fiori.landscape.domain.entities;
import uim.fiori;
class LandscapeODataController {
private:
    LandscapeService _service;
public:
    this(LandscapeService service) {
        _service = service;
    }

    void registerRoutes(URLRouter router) {
        router.get("/odata/v4/landscape-service", &getServiceDocument);
        router.get("/odata/v4/landscape-service/", &getServiceDocument);
        router.get("/odata/v4/landscape-service/$metadata", &getMetadata);
        router.post("/odata/v4/landscape-service/$batch", &postBatchUnsupported);
        router.get("/odata/v4/landscape-service/Systems", &getSystems);
        router.get("/odata/v4/landscape-service/Systems/*", &getSystemByWildcard);
        router.get("/odata/v4/landscape-service/Interfaces", &getInterfaces);
        router.get("/odata/v4/landscape-service/MatrixCells", &getMatrixCells);
        router.get("/odata/v4/landscape-service/KPIOverview", &getKPIOverview);
        router.get("/odata/v4/landscape-service/BusinessAreas", &getBusinessAreas);
        router.get("/odata/v4/landscape-service/ProcessLevels", &getProcessLevels);
    }

    void postBatchUnsupported(HTTPServerRequest req, HTTPServerResponse res) {
        Json errorRoot = Json.emptyObject;
        Json errorBody = Json.emptyObject;
        errorBody["code"] = Json("BatchNotSupported");
        errorBody["message"] = Json("$batch is not supported by this service. Use direct requests.");
        errorRoot["error"] = errorBody;
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeBody(
            errorRoot.toString(),
            cast(int) HTTPStatus.notImplemented,
            "application/json"
        );
    }

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        Json response = Json.emptyObject;
        response["@odata.context"] = Json("/odata/v4/landscape-service/$metadata");
        Json value = Json.emptyArray;
        value ~= serviceEntry("Systems");
        value ~= serviceEntry("Interfaces");
        value ~= serviceEntry("MatrixCells");
        value ~= serviceEntry("KPIOverview");
        value ~= serviceEntry("BusinessAreas");
        value ~= serviceEntry("ProcessLevels");
        response["value"] = value;
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeBody(response.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        auto metadata = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="LandscapeService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="System">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="BusinessArea" Type="Edm.String" Nullable="false"/>
        <Property Name="ProcessLevel" Type="Edm.String" Nullable="false"/>
        <Property Name="LifecycleStatus" Type="Edm.String" Nullable="false"/>
        <Property Name="OperatingModel" Type="Edm.String" Nullable="false"/>
        <Property Name="Criticality" Type="Edm.String" Nullable="false"/>
        <Property Name="StatusColor" Type="Edm.String" Nullable="false"/>
        <Property Name="BusinessOwner" Type="Edm.String" Nullable="false"/>
        <Property Name="ITOwner" Type="Edm.String" Nullable="false"/>
        <Property Name="Description" Type="Edm.String" Nullable="false"/>
      </EntityType>
      <EntityType Name="Interface">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="SourceSystemID" Type="Edm.String" Nullable="false"/>
        <Property Name="TargetSystemID" Type="Edm.String" Nullable="false"/>
        <Property Name="Protocol" Type="Edm.String" Nullable="false"/>
        <Property Name="Direction" Type="Edm.String" Nullable="false"/>
        <Property Name="Classification" Type="Edm.String" Nullable="false"/>
      </EntityType>
      <EntityType Name="MatrixCell">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="BusinessArea" Type="Edm.String" Nullable="false"/>
        <Property Name="ProcessLevel" Type="Edm.String" Nullable="false"/>
        <Property Name="Systems" Type="Edm.String" Nullable="true"/>
        <Property Name="SystemCount" Type="Edm.Int32" Nullable="false"/>
      </EntityType>
      <EntityType Name="KPIEntry">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Label" Type="Edm.String" Nullable="false"/>
        <Property Name="Value" Type="Edm.Int32" Nullable="false"/>
        <Property Name="Semantic" Type="Edm.String" Nullable="false"/>
      </EntityType>
      <EntityType Name="BusinessArea">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="SortOrder" Type="Edm.Int32" Nullable="false"/>
      </EntityType>
      <EntityType Name="ProcessLevel">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String" Nullable="false"/>
        <Property Name="SortOrder" Type="Edm.Int32" Nullable="false"/>
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Systems" EntityType="LandscapeService.System"/>
        <EntitySet Name="Interfaces" EntityType="LandscapeService.Interface"/>
        <EntitySet Name="MatrixCells" EntityType="LandscapeService.MatrixCell"/>
        <EntitySet Name="KPIOverview" EntityType="LandscapeService.KPIEntry"/>
        <EntitySet Name="BusinessAreas" EntityType="LandscapeService.BusinessArea"/>
        <EntitySet Name="ProcessLevels" EntityType="LandscapeService.ProcessLevel"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
        res.writeBody(metadata, cast(int) HTTPStatus.ok, "application/xml");
    }

    void getSystems(HTTPServerRequest req, HTTPServerResponse res) {
        auto systems = applySystemQuery(req, _service.listSystems());
        auto paged = applyPaging(req, systems);
        writeCollection(
            req,
            res,
            "Systems",
            systemsToJson(paged.values),
            paged.hasNext,
            paged.nextSkip
        );
    }

    void getSystemByWildcard(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        auto marker = "Systems('";
        auto start = path.indexOf(marker);
        if (start < 0) {
            res.writeBody("{}", cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        auto begin = cast(size_t) start + marker.length;
        auto stop = path.lastIndexOf("')");
        if (stop <= cast(int) begin) {
            res.writeBody("{}", cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        auto id = path[begin .. cast(size_t) stop];
        auto system = _service.findSystemById(id);
        if (system.id.length == 0) {
            res.writeBody("{}", cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        writeSingle(res, toSystemJson(system));
    }

    void getInterfaces(HTTPServerRequest req, HTTPServerResponse res) {
        auto systemId = getQueryOption(req, "systemId");
        auto all = systemId.length > 0 ? _service.listInterfacesForSystem(systemId) : _service.listInterfaces();
        auto paged = applyPaging(req, all);
        writeCollection(
            req,
            res,
            "Interfaces",
            interfacesToJson(paged.values),
            paged.hasNext,
            paged.nextSkip
        );
    }

    void getMatrixCells(HTTPServerRequest req, HTTPServerResponse res) {
        auto rows = _service.buildMatrixCells();
        writeCollection(req, res, "MatrixCells", matrixToJson(rows), false, 0);
    }

    void getKPIOverview(HTTPServerRequest req, HTTPServerResponse res) {
        auto values = _service.buildKPIs();
        writeCollection(req, res, "KPIOverview", kpisToJson(values), false, 0);
    }

    void getBusinessAreas(HTTPServerRequest req, HTTPServerResponse res) {
        writeCollection(
            req,
            res,
            "BusinessAreas",
            areasToJson(_service.listBusinessAreas()),
            false,
            0
        );
    }

    void getProcessLevels(HTTPServerRequest req, HTTPServerResponse res) {
        writeCollection(
            req,
            res,
            "ProcessLevels",
            levelsToJson(_service.listProcessLevels()),
            false,
            0
        );
    }
private:
    struct PagingResult(T) {
        T[] values;
        bool hasNext;
        size_t nextSkip;
    }
    string getQueryOption(HTTPServerRequest req, string key) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == key) {
                return kv.value;
            }
        }
        return "";
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
    string[] splitTopLevel(string expression, string delimiter) {
        auto lower = expression.toLower();
        auto token = delimiter.toLower();
        string[] parts;
        size_t start = 0;
        int depth = 0;
        size_t i = 0;
        while (i < expression.length) {
            if (expression[i] == '(') depth++;
            if (expression[i] == ')' && depth > 0) depth--;
            if (depth == 0 && i + token.length <= expression.length && lower[i .. i + token.length] == token) {
                parts ~= expression[start .. i].strip();
                i += token.length;
                start = i;
                continue;
            }
            i++;
        }
        parts ~= expression[start .. $].strip();
        return parts;
    }
    string trimOuterParens(string value) {
        auto current = value.strip();
        while (current.length >= 2 && current[0] == '(' && current[$ - 1] == ')') {
            int depth = 0;
            bool wraps = true;
            foreach (idx, ch; current) {
                if (ch == '(') depth++;
                if (ch == ')') {
                    depth--;
                    if (depth == 0 && idx + 1 < current.length) {
                        wraps = false;
                        break;
                    }
                }
            }
            if (!wraps) break;
            current = current[1 .. $ - 1].strip();
        }
        return current;
    }
    bool compareString(string left, string op, string right) {
        final switch (op) {
            case "eq": return left == right;
            case "ne": return left != right;
            case "gt": return left > right;
            case "ge": return left >= right;
            case "lt": return left < right;
            case "le": return left <= right;
        }
    }
    bool compareDouble(double left, string op, double right) {
        final switch (op) {
            case "eq": return left == right;
            case "ne": return left != right;
            case "gt": return left > right;
            case "ge": return left >= right;
            case "lt": return left < right;
            case "le": return left <= right;
        }
    }
    bool parseContains(string atom, out string field, out string needle) {
        auto lowered = atom.toLower();
        if (!lowered.startsWith("contains(")) {
            return false;
        }
        auto open = atom.indexOf("(");
        auto close = atom.lastIndexOf(")");
        if (open < 0 || close <= open) {
            return false;
        }
        auto parts = splitTopLevel(atom[open + 1 .. cast(size_t) close], ",");
        if (parts.length != 2) {
            return false;
        }
        field = parts[0].strip().toLower();
        needle = unquote(parts[1]).toLower();
        return true;
    }
    bool parseComparison(string atom, out string field, out string op, out string value) {
        auto lowered = atom.toLower();
        string[] ops = [" eq ", " ne ", " gt ", " ge ", " lt ", " le "];
        foreach (token; ops) {
            auto pos = lowered.indexOf(token);
            if (pos < 0) continue;
            field = atom[0 .. cast(size_t) pos].strip().toLower();
            op = token.strip();
            value = unquote(atom[cast(size_t) (pos + token.length) .. $]);
            return true;
        }
        return false;
    }
    string unquote(string value) {
        auto stripped = value.strip();
        if (stripped.length >= 2 && stripped[0] == '\'' && stripped[$ - 1] == '\'') {
            return stripped[1 .. $ - 1];
        }
        return stripped;
    }
    bool evalSystemAtom(ITSystem item, string atom) {
        string field;
        string needle;
        if (parseContains(atom, field, needle)) {
            if (field == "name") return item.name.toLower().canFind(needle);
            if (field == "businessarea") return item.businessArea.toLower().canFind(needle);
            return false;
        }
        string op;
        string value;
        if (!parseComparison(atom, field, op, value)) {
            return false;
        }
        if (field == "id") return compareString(item.id, op, value);
        if (field == "name") return compareString(item.name, op, value);
        if (field == "businessarea") return compareString(item.businessArea, op, value);
        if (field == "processlevel") return compareString(item.processLevel, op, value);
        if (field == "lifecyclestatus") return compareString(item.lifecycleStatus, op, value);
        if (field == "operatingmodel") return compareString(item.operatingModel, op, value);
        if (field == "criticality") return compareString(item.criticality, op, value);
        return false;
    }
    bool matchesExpression(string expression, bool delegate(string atom) evaluator) {
        auto cleaned = trimOuterParens(expression);
        if (cleaned.length == 0) return true;
        auto orParts = splitTopLevel(cleaned, " or ");
        foreach (orPart; orParts) {
            bool allTrue = true;
            auto andParts = splitTopLevel(orPart, " and ");
            foreach (andPart; andParts) {
                auto atom = trimOuterParens(andPart);
                if (atom.length == 0) continue;
                if (!evaluator(atom)) {
                    allTrue = false;
                    break;
                }
            }
            if (allTrue) return true;
        }
        return false;
    }
    ITSystem[] applySystemQuery(HTTPServerRequest req, ITSystem[] input) {
        auto filtered = input;
        auto filter = getQueryOption(req, "$filter").strip();
        if (filter.length > 0) {
            ITSystem[] result;
            foreach (item; input) {
                if (matchesExpression(filter, atom => evalSystemAtom(item, atom))) {
                    result ~= item;
                }
            }
            filtered = result;
        }
        auto orderBy = split(getQueryOption(req, "$orderby").strip(), " ");
        if (orderBy.length > 0 && orderBy[0].length > 0) {
            auto field = orderBy[0].toLower();
            auto desc = orderBy.length > 1 && orderBy[1].toLower() == "desc";
            auto result = filtered.dup;
            if (field == "name") sort!((a, b) => a.name < b.name)(result);
            if (field == "criticality") sort!((a, b) => a.criticality < b.criticality)(result);
            if (field == "businessarea") sort!((a, b) => a.businessArea < b.businessArea)(result);
            if (desc) reverse(result);
            filtered = result;
        }
        return filtered;
    }
    PagingResult!T applyPaging(T)(HTTPServerRequest req, T[] values) {
        auto skip = parseSizeT(getQueryOption(req, "$skip"), 0);
        auto rawTop = getQueryOption(req, "$top").strip();
        auto start = min(skip, values.length);
        auto end = values.length;
        bool hasNext;
        if (rawTop.length > 0) {
            auto top = parseSizeT(rawTop, values.length);
            end = min(start + top, values.length);
            hasNext = end < values.length;
        }
        if (start >= end) {
            return PagingResult!T([], false, end);
        }
        return PagingResult!T(values[start .. end].dup, hasNext, end);
    }
    string buildNextLink(HTTPServerRequest req, string entitySet, size_t nextSkip) {
        string[] params;
        bool hasSkip;
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "$skip") {
                params ~= "$skip=" ~ to!string(nextSkip);
                hasSkip = true;
            } else {
                params ~= kv.key ~ "=" ~ kv.value;
            }
        }
        if (!hasSkip) {
            params ~= "$skip=" ~ to!string(nextSkip);
        }
        return "/odata/v4/landscape-service/" ~ entitySet ~ "?" ~ params.join("&");
    }

    void writeCollection(
        HTTPServerRequest req,
        HTTPServerResponse res,
        string entitySet,
        Json value,
        bool hasNext,
        size_t nextSkip
    ) {
        Json response = Json.emptyObject;
        response["@odata.context"] = Json("$metadata#" ~ entitySet);
        if (hasNext) {
            response["@odata.nextLink"] = Json(buildNextLink(req, entitySet, nextSkip));
        }
        response["value"] = value;
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeBody(response.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void writeSingle(HTTPServerResponse res, Json value) {
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeBody(value.toString(), cast(int) HTTPStatus.ok, "application/json");
    }
    Json serviceEntry(string name) {
        Json item = Json.emptyObject;
        item["name"] = Json(name);
        item["kind"] = Json("EntitySet");
        item["url"] = Json(name);
        return item;
    }
    Json toSystemJson(ITSystem entry) {
        Json item = Json.emptyObject;
        item["ID"] = Json(entry.id);
        item["Name"] = Json(entry.name);
        item["BusinessArea"] = Json(entry.businessArea);
        item["ProcessLevel"] = Json(entry.processLevel);
        item["LifecycleStatus"] = Json(entry.lifecycleStatus);
        item["OperatingModel"] = Json(entry.operatingModel);
        item["Criticality"] = Json(entry.criticality);
        item["StatusColor"] = Json(entry.statusColor);
        item["BusinessOwner"] = Json(entry.businessOwner);
        item["ITOwner"] = Json(entry.itOwner);
        item["Description"] = Json(entry.description);
        return item;
    }
    Json systemsToJson(ITSystem[] systems) {
        Json arr = Json.emptyArray;
        foreach (entry; systems) {
            arr ~= toSystemJson(entry);
        }
        return arr;
    }
    Json interfacesToJson(InterfaceLink[] links) {
        Json arr = Json.emptyArray;
        foreach (link; links) {
            Json item = Json.emptyObject;
            item["ID"] = Json(link.id);
            item["SourceSystemID"] = Json(link.sourceSystemId);
            item["TargetSystemID"] = Json(link.targetSystemId);
            item["Protocol"] = Json(link.protocol);
            item["Direction"] = Json(link.direction);
            item["Classification"] = Json(link.classification);
            arr ~= item;
        }
        return arr;
    }
    Json matrixToJson(MatrixCell[] rows) {
        Json arr = Json.emptyArray;
        foreach (row; rows) {
            Json item = Json.emptyObject;
            item["ID"] = Json(row.id);
            item["BusinessArea"] = Json(row.businessArea);
            item["ProcessLevel"] = Json(row.processLevel);
            item["Systems"] = Json(row.systems);
            item["SystemCount"] = Json(row.systemCount);
            arr ~= item;
        }
        return arr;
    }
    Json kpisToJson(KPIEntry[] values) {
        Json arr = Json.emptyArray;
        foreach (kpi; values) {
            Json item = Json.emptyObject;
            item["ID"] = Json(kpi.id);
            item["Label"] = Json(kpi.label);
            item["Value"] = Json(kpi.value);
            item["Semantic"] = Json(kpi.semantic);
            arr ~= item;
        }
        return arr;
    }
    Json areasToJson(BusinessArea[] values) {
        Json arr = Json.emptyArray;
        foreach (area; values) {
            Json item = Json.emptyObject;
            item["ID"] = Json(area.id);
            item["Name"] = Json(area.name);
            item["SortOrder"] = Json(area.sortOrder);
            arr ~= item;
        }
        return arr;
    }
    Json levelsToJson(ProcessLevel[] values) {
        Json arr = Json.emptyArray;
        foreach (level; values) {
            Json item = Json.emptyObject;
            item["ID"] = Json(level.id);
            item["Name"] = Json(level.name);
            item["SortOrder"] = Json(level.sortOrder);
            arr ~= item;
        }
        return arr;
    }
}
