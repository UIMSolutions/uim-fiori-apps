module uim.fiori.helpers.fiori;

public:
import uim.fiori;

// Hilfsmethode: Garantiert, dass OData-Header bei JEDER Antwort gesetzt sind
void writeODataJson(T)(HTTPServerResponse res, T data, HTTPStatus status = HTTPStatus
        .ok) {
    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    res.writeJsonBody(data, status);
}

void handleCORS(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("Handling CORS for request: ", req.method, " ", req.requestURL);

    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PATCH, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, X-CSRF-Token";
    
    // Wenn es ein OPTIONS Preflight-Request ist, sofort beenden
    if (req.method == HTTPMethod.OPTIONS) {
        res.statusCode = HTTPStatus.ok;
        res.writeBody("");
        return;
    }
}

void checkAuth(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("Checking Authorization for request: ", req.method, " ", req.requestURL);

    auto authHeader = req.headers.get("Authorization", "");
    
    if (!authHeader.startsWith("Bearer ")) {
        res.statusCode = HTTPStatus.unauthorized;
        writeODataJson(res, ["error": "Missing or invalid Authorization header"], HTTPStatus.unauthorized);
        return;
    }
    
    string token = authHeader[7 .. $];
    // Optional: JWT-Token verifizieren (z. B. via Public Key von XSUAA)
    // res.headers["X-CSRF-Token"] = "Fetch"; // Beispiel: CSRF-Token setzen
    // res.headers["OData-Version"] = "4.0"; // OData-Version setzen
    // res.writeBody(""); // Weiterleitung an den nächsten Handler 
}

void setODataHeaders(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["OData-Version"] = "4.0";
    // Optional: CORS-Header falls Fiori über einen anderen Port/Origin läuft
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, OData-MaxVersion";
}