module scanner_middleware.infrastructure.gtt.sap_gtt_http_gateway;

import std.conv : to;
import std.format : format;

import vibe.core.log : logWarn;
import vibe.data.json : Json;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod;

import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : SapGttGateway;

class SapGttHttpGateway : SapGttGateway {
    private string m_endpoint;
    private string m_authToken;

    this(string endpoint, string authToken = "") {
        m_endpoint = endpoint;
        m_authToken = authToken;
    }

    override bool forwardScan(ScanEvent eventData, out string message) {
        if (m_endpoint.length == 0) {
            message = "SAP_GTT_ENDPOINT ist nicht konfiguriert";
            return false;
        }

        auto payload = toSapGttPayload(eventData).toString();

        try {
            auto response = requestHTTP(m_endpoint, (scope req) {
                req.method = HTTPMethod.POST;
                req.headers["Content-Type"] = "application/json";
                if (m_authToken.length > 0) {
                    req.headers["Authorization"] = "Bearer " ~ m_authToken;
                }
                req.writeBody(cast(ubyte[]) payload, "application/json");
            });
            if (response.statusCode >= 200 && response.statusCode < 300) {
                message = "HTTP " ~ response.statusCode.to!string;
                return true;
            }

            message = format("HTTP %s", response.statusCode);
            return false;
        } catch (Exception ex) {
            logWarn("SAP GTT forwarding failed: %s", ex.msg);
            message = ex.msg;
            return false;
        }
    }

    private Json toSapGttPayload(ScanEvent eventData) {
        Json payload = Json.emptyObject
        .set("eventId", Json(eventData.eventId))
        .set("scannerId", Json(eventData.scannerId))
        .set("materialNumber", Json(eventData.materialNumber))
        .set("quantity", Json(cast(long) eventData.quantity))
        .set("location", Json(eventData.location))
        .set("scannedAt", Json(eventData.scannedAt.toISOString()))
        .set("sourceSystem", Json("HANDSCANNER_MIDDLEWARE"));
        return payload;
    }
}

unittest {
    import std.datetime : Clock;

    auto gateway = new SapGttHttpGateway("");
    auto eventData = ScanEvent("e1", "s1", "m1", 1, "l1", Clock.currTime(), "{}");
    string message;
    auto ok = gateway.forwardScan(eventData, message);
    assert(!ok);
    assert(message.length > 0);
}
