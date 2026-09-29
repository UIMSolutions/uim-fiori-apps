module uim.fiori_blocks.presentation.odata.users;

import uim.fiori_blocks;
import std.conv : to;

@safe:

struct UserRecord {
  string id;
  string username;
  string email;
  string role;
  bool active;

  Json toJson() const {
    auto j = Json.emptyObject;
    j["ID"] = Json(id);
    j["Username"] = Json(username);
    j["Email"] = Json(email);
    j["Role"] = Json(role);
    j["Active"] = Json(active);
    return j;
  }
}

class UserODataController : ODataController {
  private UserRecord[] _users;

  this() {
    _users = [
      UserRecord("USR-001", "admin", "admin@example.com", "Administrator", true),
      UserRecord("USR-002", "editor", "editor@example.com", "Editor", true),
      UserRecord("USR-003", "viewer", "viewer@example.com", "Viewer", false)
    ];
  }

  Json getEntitySet(string entitySetName, string expand = "") {
    if (entitySetName != "Users") {
      return Json.emptyArray;
    }

    return _users.map!(u => u.toJson).array.toJson;
  }

  Json getEntity(string entitySetName, string id, string expand = "") {
    if (entitySetName != "Users") {
      return Json.emptyObject;
    }

    auto idx = _findIndexById(id);
    return idx < 0 ? Json.emptyObject : _users[idx].toJson;
  }

  Json createEntity(string entitySetName, Json payload) {
    if (entitySetName != "Users") {
      return Json.emptyObject;
    }

    auto sId = _getString(payload, "ID", "USR-" ~ _nextNumber());
    auto sUsername = _getString(payload, "Username", "");
    auto sEmail = _getString(payload, "Email", "");
    auto sRole = _getString(payload, "Role", "Viewer");
    auto bActive = _getBool(payload, "Active", true);

    auto user = UserRecord(sId, sUsername, sEmail, sRole, bActive);
    _users ~= user;
    return user.toJson;
  }

  Json updateEntity(string entitySetName, string id, Json payload) {
    if (entitySetName != "Users") {
      return Json.emptyObject;
    }

    auto idx = _findIndexById(id);
    if (idx < 0) {
      return Json.emptyObject;
    }

    auto user = _users[idx];
    user.username = _getString(payload, "Username", user.username);
    user.email = _getString(payload, "Email", user.email);
    user.role = _getString(payload, "Role", user.role);
    user.active = _getBool(payload, "Active", user.active);
    _users[idx] = user;

    return user.toJson;
  }

  bool deleteEntity(string entitySetName, string id) {
    if (entitySetName != "Users") {
      return false;
    }

    auto idx = _findIndexById(id);
    if (idx < 0) {
      return false;
    }

    _users = _users[0 .. idx] ~ _users[idx + 1 .. $];
    return true;
  }

  BatchResponseItem response(BatchRequestItem item) {
    auto response = BatchResponseItem(item.id, 200, Json.emptyObject);

    switch (item.method) {
    case "GET":
      auto urlParts = item.url.split("?");
      if (urlParts.length > 0 && urlParts[0] == "Users") {
        response.body = Json.emptyObject
          .set("@odata.context", "$metadata#Users")
          .set("value", _users.map!(u => u.toJson).array.toJson);
      }
      break;
    case "POST":
      break;
    case "PATCH":
      break;
    case "DELETE":
      break;
    default:
      break;
    }

    return response;
  }

  private int _findIndexById(string id) const {
    foreach (i, user; _users) {
      if (user.id == id) {
        return cast(int) i;
      }
    }

    return -1;
  }

  private string _nextNumber() const {
    auto n = _users.length + 1;
    if (n < 10) {
      return "00" ~ to!string(n);
    }
    if (n < 100) {
      return "0" ~ to!string(n);
    }
    return to!string(n);
  }

  private string _getString(Json payload, string key, string fallback = "") const {
    if (key in payload) {
      return payload[key].get!string;
    }
    return fallback;
  }

  private bool _getBool(Json payload, string key, bool fallback = false) const {
    if (key in payload) {
      return payload[key].get!bool;
    }
    return fallback;
  }
}