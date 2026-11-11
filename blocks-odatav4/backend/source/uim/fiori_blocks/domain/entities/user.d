/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities.user;

@safe:

/// Application user (managed in the UserManagement view).
struct User {
  enum entitySet = "Users";
  enum idPrefix = "USR";

  string ID;
  string Username;
  string Email;
  string Role; /// see `UserRole` enumeration
  bool Active = true;
}
