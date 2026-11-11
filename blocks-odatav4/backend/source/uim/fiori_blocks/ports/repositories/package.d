/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.repositories;

/// Driven port: business data access for one entity type.
/// Implemented by `persistence.repositories`.
@safe:

interface IRepository(T) {
  /// All entities, ordered by ID.
  T[] findAll();

  /// Looks up an entity; returns false if it does not exist.
  bool tryFind(string id, out T entity);

  bool exists(string id);

  size_t count();

  /// Inserts or replaces the entity with the same ID.
  void save(T entity);

  /// Removes the entity; returns false if it did not exist.
  bool remove(string id);

  /// Replaces the complete content (used for import and transactional rollback).
  void replaceAll(T[] entities);
}
