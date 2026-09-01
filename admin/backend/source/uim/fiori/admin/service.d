module uim.fiori.admin.service;

import vibe.d;
import std.conv : to;
import std.string : startsWith;
import uim.fiori.admin.models;

@safe:

class AdminService {
private:
    UserRepository m_repo;

public:
    this() {
        m_repo = new UserRepository();
    }

    void registerRoutes(URLRouter router) {
        router.any("*", &enableCORS);

        router.get("/health", &health);

        router.get("/odata/v4/admin/$metadata", &metadata);
        router.get("/odata/v4/admin/Users", &listUsers);
        router.post("/odata/v4/admin/Users", &createUser);

        // Wildcard is kept at route end and supports /Users/<id> endpoints.
        router.get("/odata/v4/admin/Users/*", &getUser);
        router.put("/odata/v4/admin/Users/*", &updateUser);
        router.delete_("/odata/v4/admin/Users/*", &deleteUser);
    }

private:
    void enableCORS(HTTPServerRequest req, HTTPServerResponse res) {
        res.headers["Access-Control-Allow-Origin"] = "*";
        res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
        res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, X-Requested-With";

        if (req.method == HTTPMethod.OPTIONS) {
            res.writeBody("", 200);
        }
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        Json responseJson = Json.emptyObject;
        responseJson["status"] = Json("UP");
        responseJson["service"] = Json("admin-backend");
        res.writeJsonBody(responseJson);
    }

    void metadata(HTTPServerRequest req, HTTPServerResponse res) {
        immutable xml = `<?xml version="1.0" encoding="UTF-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="AdminService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="User">
        <Key>
          <PropertyRef Name="id" />
        </Key>
        <Property Name="id" Type="Edm.String" Nullable="false" />
        <Property Name="username" Type="Edm.String" Nullable="false" />
        <Property Name="email" Type="Edm.String" Nullable="false" />
        <Property Name="role" Type="Edm.String" Nullable="false" />
        <Property Name="active" Type="Edm.Boolean" Nullable="false" />
        <Property Name="createdAt" Type="Edm.String" Nullable="false" />
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Users" EntityType="AdminService.User" />
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;

        res.contentType = "application/xml; charset=utf-8";
        res.writeBody(xml, cast(int) HTTPStatus.ok, "application/xml; charset=utf-8");
    }

    void listUsers(HTTPServerRequest req, HTTPServerResponse res) {
        Json responseJson = Json.emptyObject;
        responseJson["@odata.context"] = Json("$metadata#Users");

        Json values = Json.emptyArray;
        foreach (u; m_repo.list()) {
            values.appendArrayElement(toJson(u));
        }
        responseJson["value"] = values;

        res.writeJsonBody(responseJson);
    }

    void getUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);
        if (id.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing user id");
        }

        auto user = m_repo.getById(id);
        if (user.id.length == 0) {
            throw new HTTPStatusException(HTTPStatus.notFound, "User not found");
        }

        Json responseJson = toJson(user);
        responseJson["@odata.context"] = Json("$metadata#Users/$entity");
        res.writeJsonBody(responseJson);
    }

    void createUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto payload = req.json;

        AdminUser u;
        u.username = readString(payload, "username", "");
        u.email = readString(payload, "email", "");
        u.role = readString(payload, "role", "Viewer");
        u.active = readBool(payload, "active", true);

        if (u.username.length == 0 || u.email.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "username and email are required");
        }

        auto created = m_repo.create(u);
        res.statusCode = cast(int) HTTPStatus.created;
        res.writeJsonBody(toJson(created));
    }

    void updateUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);
        if (id.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing user id");
        }

        auto payload = req.json;

        AdminUser updated;
        updated.username = readString(payload, "username", "");
        updated.email = readString(payload, "email", "");
        updated.role = readString(payload, "role", "Viewer");
        updated.active = readBool(payload, "active", true);
        updated.createdAt = readString(payload, "createdAt", "");

        if (updated.username.length == 0 || updated.email.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "username and email are required");
        }

        auto updatedUser = m_repo.update(id, updated);
        if (updatedUser.id.length == 0) {
            throw new HTTPStatusException(HTTPStatus.notFound, "User not found");
        }

        res.writeJsonBody(toJson(updatedUser));
    }

    void deleteUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req);
        if (id.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing user id");
        }

        if (!m_repo.remove(id)) {
            throw new HTTPStatusException(HTTPStatus.notFound, "User not found");
        }

        res.statusCode = cast(int) HTTPStatus.noContent;
        res.writeBody("");
    }

    string extractId(HTTPServerRequest req) {
        auto path = req.requestPath.to!string;
        immutable base = "/odata/v4/admin/Users/";
        if (!path.startsWith(base)) {
            return "";
        }
        return path[base.length .. $];
    }

    Json toJson(const AdminUser user) {
        Json responseJson = Json.emptyObject;
        responseJson["id"] = Json(user.id);
        responseJson["username"] = Json(user.username);
        responseJson["email"] = Json(user.email);
        responseJson["role"] = Json(user.role);
        responseJson["active"] = Json(user.active);
        responseJson["createdAt"] = Json(user.createdAt);
        return responseJson;
    }

    string readString(Json payload, string key, string fallback) {
        if (!(key in payload)) {
            return fallback;
        }
        try {
            return payload[key].get!string;
        } catch (Exception) {
            return fallback;
        }
    }

    bool readBool(Json payload, string key, bool fallback) {
        if (!(key in payload)) {
            return fallback;
        }
        try {
            return payload[key].get!bool;
        } catch (Exception) {
            return fallback;
        }
    }
}
