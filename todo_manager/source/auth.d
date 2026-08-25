module auth;

import vibe.d;
import std.base64 : Base64URL;
import std.string : startsWith, split;
import std.algorithm : canFind;
import uim.framework;

struct JwtPayload {
    string client_id;
    string user_name;
    string[] scope_;
}

// Extrahiert und parst den Payload-Teil des JWT
Nullable!JwtPayload parseJwtPayload(string authHeader) {
    Nullable!JwtPayload result;

    if (!authHeader.startsWith("Bearer ")) return result;
    
    string token = authHeader[7 .. $];
    auto parts = token.split(".");
    if (parts.length != 3) return result; // Header.Payload.Signature

    try {
        // Base64URL Padding ausgleichen
        string payloadB64 = parts[1];
        while (payloadB64.length % 4 != 0) payloadB64 ~= "=";

        auto decodedBytes = Base64URL.decode(payloadB64);
        Json jsonPayload = parseJsonString(cast(string)decodedBytes);

        JwtPayload payload;
        if ("client_id" in jsonPayload) payload.client_id = jsonPayload["client_id"].get!string;
        if ("user_name" in jsonPayload) payload.user_name = jsonPayload["user_name"].get!string;

        if ("scope" in jsonPayload && jsonPayload["scope"].type == Json.Type.array) {
            foreach (Json s; jsonPayload["scope"]) {
                payload.scope_ ~= s.get!string;
            }
        }

        result = payload;
    } catch (Exception e) {
        logError("Fehler beim Parsen des JWT-Tokens: %s", e.msg);
    }

    return result;
}

// Middleware zur Scope-Prüfung
bool requireScope(HTTPServerRequest req, HTTPServerResponse res, string requiredScope) {
    auto authHeader = req.headers.get("Authorization", "");
    auto payload = parseJwtPayload(authHeader);

    if (payload.isNull) {
        res.writeBody(
            "{\"error\":\"Nicht authentifiziert oder ungueltiges Token\"}",
            cast(int)HTTPStatus.unauthorized,
            "application/json"
        );
        return false;
    }

    // XSUAA Scopes haben auf BTP meist das Format: <xsappname>.<ScopeName>
    bool hasPermission = payload.get.scope_.canFind!(s => s.endsWith("." ~ requiredScope) || s == requiredScope);

    if (!hasPermission) {
        res.writeBody(
            "{\"error\":\"Keine ausreichenden Berechtigungen fuer diesen Scope\"}",
            cast(int)HTTPStatus.forbidden,
            "application/json"
        );
        return false;
    }

    return true;
}