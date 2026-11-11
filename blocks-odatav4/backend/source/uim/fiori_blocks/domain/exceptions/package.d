/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.exceptions;

/// Business exceptions. Adapters (OData, CLI, GUI) map them to their own error representation
/// (e.g. HTTP 404 / 400 / 409).
@safe:

/// Base class of all business exceptions.
class DomainException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// An entity with the given key does not exist.
class EntityNotFoundException : DomainException {
  string entityType;
  string id;

  this(string entityType, string id, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    this.entityType = entityType;
    this.id = id;
    super(entityType ~ " '" ~ id ~ "' not found", file, line);
  }
}

/// An entity violates a business rule.
class ValidationException : DomainException {
  string[] violations;

  this(string[] violations, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    import std.array : join;

    this.violations = violations;
    super(violations.join("; "), file, line);
  }

  this(string violation, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    this([violation], file, line);
  }
}

/// An entity with the same key already exists.
class ConflictException : DomainException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}
