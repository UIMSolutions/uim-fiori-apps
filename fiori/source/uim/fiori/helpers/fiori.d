module uim.fiori.helpers.fiori;
import uim.fiori;
import vibe.data.serialization : name;

@safe:
// Hilfsmethode: Garantiert, dass OData-Header bei JEDER Antwort gesetzt sind
void writeODataJson(T)(HTTPServerResponse res, T data, HTTPStatus status = HTTPStatus
        .ok) {
    res.headers["OData-Version"] = "4.0";
    res.headers["Content-Type"] = "application/json;odata.metadata=minimal;charset=utf-8";
    res.writeJsonBody(data, status);
}
/// Middleware zur Behandlung von Cross-Origin Resource Sharing (CORS)
/// Dies erlaubt dem UI5 Dev-Server (z.B. Port 3000) Anfragen an das vibe.d Backend zu stellen.
void enableCORS(HTTPServerRequest req, HTTPServerResponse res) {
    writeln("Enabling CORS for request: ", req.method, " ", req.requestURL);
    // Erlaube Zugriffe von jedem Ursprung (für lokale Entwicklung)
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS";
    // Web browsers might require the following headers for CORS preflight requests
    // res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, X-Requested-With";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, OData-Version, X-CSRF-Token";
    // Preflight-Anfragen (OPTIONS) direkt mit 200 OK beantworten
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
        writeODataJson(res, ["error": "Missing or invalid Authorization header"], HTTPStatus
                .unauthorized);
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

string extractContentType(string content) {
    foreach (line; content.split("\r\n")) {
        if (line.canFind("Content-Type:")) {
            auto parts = line.split(":");
            if (parts.length == 2)
                return parts[1].strip();
        }
    }
    return "";
}

string extractContentEncoding(string content) {
    foreach (line; content.split("\r\n")) {
        if (line.canFind("Content-Transfer-Encoding:")) {
            auto parts = line.split(":");
            if (parts.length == 2)
                return parts[1].strip();
        }
    }
    return "";
}

string readString(Bson doc, string key, string fallback = "") {
    Bson value;
    if (tryGet(doc, key, value)) {
        return value.to!string;
    }
    return fallback;
}

double readDouble(Bson doc, string key, double fallback = 0) {
    Bson value;
    if (!tryGet(doc, key, value)) {
        return fallback;
    }
    switch (value.type) with (Bson.Type) {
    case double_:
        return value.get!double;
    case int_:
        return cast(double)value.get!int;
    case long_:
        return cast(double)value.get!long;
    case string:
        return value.to!double;
    default:
        return fallback;
    }
}

bool tryGet(Bson doc, string key, out Bson value) {
    if (doc.type != Bson.Type.object) {
        return false;
    }
    auto map = doc.get!(Bson[string]);
    if (auto found = key in map) {
        value = *found;
        return true;
    }
    return false;
}

struct ODataResponse(T) {
    import vibe.data.serialization : name;
    
    @name("@odata.context") string context;
    @name("value") T[] value;
}
