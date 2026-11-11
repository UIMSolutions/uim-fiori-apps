/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.security;

/// Security utilities.
///
/// `DemoAuthenticator` backs the login view for local development. On SAP BTP the approuter
/// authenticates against XSUAA and forwards the JWT (`Authorization: Bearer ...`); see
/// `bearerToken` and approuter/xs-security.json.
import std.algorithm : startsWith;
import std.string : strip;

import uim.fiori_blocks.ports.services;

@safe:

/// Demo users with a shared password from the configuration (`demoPassword` / BLOCKS_DEMO_PASSWORD).
class DemoAuthenticator : IAuthenticator {
  private string _password;
  private string[string] _roles;

  this(string password, string[string] roles = ["admin": "Administrator", "viewer": "Viewer"]) {
    _password = password;
    _roles = roles;
  }

  AuthResult authenticate(string username, string password) {
    auto role = username in _roles;
    if (role is null || password.length == 0 || !constantTimeEquals(password, _password))
      return AuthResult(false, "", "", "Benutzername oder Passwort ungueltig.");
    return AuthResult(true, username, *role, "");
  }
}

/// Compares two strings in constant time (with respect to the content).
bool constantTimeEquals(string a, string b) pure nothrow @nogc {
  if (a.length != b.length)
    return false;
  ubyte diff;
  foreach (i; 0 .. a.length)
    diff |= a[i] ^ b[i];
  return diff == 0;
}

/// Extracts the token of an "Authorization: Bearer <token>" header ("" if missing).
string bearerToken(string authorizationHeader) pure {
  enum prefix = "Bearer ";
  return authorizationHeader.startsWith(prefix) ? authorizationHeader[prefix.length .. $].strip : "";
}

///
unittest {
  auto auth = new DemoAuthenticator("secret");
  assert(auth.authenticate("admin", "secret").role == "Administrator");
  assert(!auth.authenticate("admin", "wrong").authenticated);
  assert(!auth.authenticate("nobody", "secret").authenticated);
  assert(bearerToken("Bearer abc ") == "abc");
  assert(bearerToken("Basic abc") == "");
}
