module scanner_middleware.presentation.http.odata_controller;

import std.conv : to;
import std.string : strip, indexOf;

import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : ScanRepository;

class ODataController {
    private ScanRepository m_repository;

    this(ScanRepository repository) {
        m_repository = repository;
    }

    void registerRoutes(URLRouter router) {
        router.get("/odata/v4/scanner-service", &getServiceDocument);
        router.get("/odata/v4/scanner-service/", &getServiceDocument);
        router.get("/odata/v4/scanner-service/$metadata", &getMetadata);
        router.get("/odata/v4/scanner-service/Scans", &getScans);
        router.get("/odata/v4/scanner-service/Scans*", &getScanByKey);
    }

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["@odata.context"] = Json("$metadata");

        Json values = Json.emptyArray;
        Json scans = Json.emptyObject;
        scans["name"] = Json("Scans");
        scans["kind"] = Json("EntitySet");
        scans["url"] = Json("Scans");
        values ~= scans;

        payload["value"] = values;
        writeODataJson(res, payload.toString());
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        auto metadata = q{
<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="ScannerService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Scan">
        <Key>
          <PropertyRef Name="EventID"/>
        </Key>
        <Property Name="EventID" Type="Edm.String" Nullable="false"/>
        <Property Name="ScannerID" Type="Edm.String" Nullable="false"/>
        <Property Name="MaterialNumber" Type="Edm.String" Nullable="false"/>
        <Property Name="Quantity" Type="Edm.Int64" Nullable="false"/>
        <Property Name="Location" Type="Edm.String" Nullable="false"/>
        <Property Name="ScannedAt" Type="Edm.DateTimeOffset" Nullable="false"/>
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Scans" EntityType="ScannerService.Scan"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>
};
        res.headers["OData-Version"] = "4.0";
        res.writeBody(metadata, 200, "application/xml");
    }

    void getScans(HTTPServerRequest req, HTTPServerResponse res) {
        size_t limit = 200;
        if ("$top" in req.query) {
            limit = to!size_t(req.query.get("$top", "200"));
        }

        auto items = m_repository.listRecent(limit);
        Json payload = Json.emptyObject;
        payload["@odata.context"] = Json("$metadata#Scans");
        payload["value"] = toEntityArray(items);
        writeODataJson(res, payload.toString());
    }

    void getScanByKey(HTTPServerRequest req, HTTPServerResponse res) {
        auto key = extractKeyFromPath(req.requestURL.to!string);
        if (key.length == 0) {
            getScans(req, res);
            return;
        }

        auto items = m_repository.listRecent(500);
        foreach (item; items) {
            if (item.eventId == key) {
                Json payload = Json.emptyObject;
                payload["@odata.context"] = Json("$metadata#Scans/$entity");
                payload["EventID"] = Json(item.eventId);
                payload["ScannerID"] = Json(item.scannerId);
                payload["MaterialNumber"] = Json(item.materialNumber);
                payload["Quantity"] = Json(cast(long) item.quantity);
                payload["Location"] = Json(item.location);
                payload["ScannedAt"] = Json(item.scannedAt.toISOString());
                writeODataJson(res, payload.toString());
                return;
            }
        }

        Json errorPayload = Json.emptyObject;
        errorPayload["error"] = Json("Scan nicht gefunden");
        writeODataJson(res, errorPayload.toString(), 404);
    }

    private string extractKeyFromPath(string path) {
        auto marker = "Scans(";
        auto start = path.indexOf(marker);
        if (start < 0) {
            return "";
        }

        auto suffix = path[start + marker.length .. $];
        auto end = suffix.indexOf(")");
        if (end < 0) {
            return "";
        }

        auto key = suffix[0 .. end].strip;
        if (key.length >= 2 && key[0] == '\'' && key[$ - 1] == '\'') {
            return key[1 .. $ - 1];
        }

        return key;
    }

    private Json toEntityArray(ScanEvent[] items) {
        Json values = Json.emptyArray;
        foreach (item; items) {
            Json entry = Json.emptyObject;
            entry["EventID"] = Json(item.eventId);
            entry["ScannerID"] = Json(item.scannerId);
            entry["MaterialNumber"] = Json(item.materialNumber);
            entry["Quantity"] = Json(cast(long) item.quantity);
            entry["Location"] = Json(item.location);
            entry["ScannedAt"] = Json(item.scannedAt.toISOString());
            values ~= entry;
        }
        return values;
    }

    private void writeODataJson(HTTPServerResponse res, string body, int status = 200) {
        res.headers["OData-Version"] = "4.0";
        res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
        res.writeBody(body, status, "application/json");
    }
}
