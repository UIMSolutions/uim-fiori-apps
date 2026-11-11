/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.services.validation;

import std.algorithm : canFind;
import std.string : strip;

import uim.fiori_blocks.domain.entities;
import uim.fiori_blocks.domain.enumerations;
import uim.fiori_blocks.domain.exceptions;

@safe:

/// Collects all business rule violations of `entity` (empty result = valid).
string[] violationsOf(T)(const ref T entity) pure {
  string[] errors;

  if (entity.ID.strip.length == 0)
    errors ~= "ID must not be empty";

  static if (is(typeof(T.init.Name) == string)) {
    if (entity.Name.strip.length == 0)
      errors ~= "Name must not be empty";
  }

  static if (is(T == SolutionBlock)) {
    if (entity.ValidFrom.length && entity.ValidUntil.length && entity.ValidFrom > entity.ValidUntil)
      errors ~= "ValidFrom (" ~ entity.ValidFrom ~ ") must not be after ValidUntil (" ~ entity.ValidUntil ~ ")";
  }

  static if (is(T == User)) {
    if (entity.Username.strip.length == 0)
      errors ~= "Username must not be empty";
    if (entity.Email.length && !entity.Email.canFind('@'))
      errors ~= "Email '" ~ entity.Email ~ "' is not a valid e-mail address";
    if (!isAllowedValue!UserRole(entity.Role))
      errors ~= "Role must be one of: " ~ allowedValues!UserRole;
  }

  static if (is(typeof(T.init.DependsOn) == Dependency[]))
    errors ~= dependencyViolations(entity.ID, entity.DependsOn);
  static if (is(typeof(T.init.DependsOnSolutionBlocks) == Dependency[]))
    errors ~= dependencyViolations(entity.ID, entity.DependsOnSolutionBlocks);

  return errors;
}

/// Throws a `ValidationException` if `entity` breaks a business rule.
void validate(T)(const ref T entity) pure {
  auto errors = violationsOf(entity);
  if (errors.length)
    throw new ValidationException(errors);
}

private string[] dependencyViolations(string ownerId, const Dependency[] dependencies) pure {
  string[] errors;
  foreach (dep; dependencies) {
    if (dep.ID.strip.length == 0)
      errors ~= "Dependency ID must not be empty";
    else if (dep.ID == ownerId)
      errors ~= "A block must not depend on itself (" ~ ownerId ~ ")";
    if (!isAllowedValue!Criticality(dep.Criticality))
      errors ~= "Dependency criticality must be one of: " ~ allowedValues!Criticality;
  }
  return errors;
}

///
unittest {
  auto ok = ArchitectureBlock("AB-01", "Core");
  assert(violationsOf(ok).length == 0);

  auto noName = ArchitectureBlock("AB-01");
  assert(violationsOf(noName).length == 1);

  auto selfRef = BaseBlock("BB-01", "X");
  selfRef.DependsOn = [Dependency("BB-01", "X", "Uses", "High")];
  assert(violationsOf(selfRef).length == 1);

  auto period = SolutionBlock("SB-01", "S");
  period.ValidFrom = "2026-12-31";
  period.ValidUntil = "2026-01-01";
  assert(violationsOf(period).length == 1);

  auto user = User("USR-001", "admin", "no-mail", "Root");
  assert(violationsOf(user).length == 2);

  bool thrown;
  try
    validate(noName);
  catch (ValidationException)
    thrown = true;
  assert(thrown);
}
