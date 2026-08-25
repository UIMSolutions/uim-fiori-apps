module helpers.helper;

import uim.framework;

// Hilfsmethode: Garantiert, dass OData-Header bei JEDER Antwort gesetzt sind
void writeODataJson(T)(HTTPServerResponse res, T data, HTTPStatus status = HTTPStatus
        .ok) {
    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    res.writeJsonBody(data, status);
}
