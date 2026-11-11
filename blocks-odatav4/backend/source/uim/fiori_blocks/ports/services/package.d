/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.services;

/// Ports for application-wide services.
@safe:

/// Result of an authentication attempt.
struct AuthResult {
  bool authenticated;
  string username;
  string role;
  string message;
}

/// Driven port: verifies user credentials (demo implementation or XSUAA in production).
interface IAuthenticator {
  AuthResult authenticate(string username, string password);
}
