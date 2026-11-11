/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.usecases;

/// Driving port: managing the entities of one type (CRUD with business rules).
/// Implemented by `application.usecases.ManageEntitiesUseCase`.
@safe:

interface IManageEntities(T) {
  T[] list();

  /// Throws `EntityNotFoundException`.
  T get(string id);

  bool exists(string id);

  size_t count();

  /// Creates a new entity. An empty ID is generated. Throws `ConflictException`, `ValidationException`.
  T create(T entity);

  /// Replaces an existing entity (PUT semantics). Throws `EntityNotFoundException`, `ValidationException`.
  T replace(string id, T entity);

  /// Partially updates an existing entity (PATCH semantics).
  T modify(string id, scope void delegate(ref T entity) @safe change);

  /// Throws `EntityNotFoundException`.
  void remove(string id);

  /// Replaces all entities after validating each one (import / rollback).
  void replaceAll(T[] entities);
}
