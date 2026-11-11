/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.application.usecases;

/// Use cases / interactors.
import std.algorithm : map;
import std.array : array;

import uim.fiori_blocks.domain;
import uim.fiori_blocks.ports.repositories;
import uim.fiori_blocks.ports.usecases;

@safe:

/// CRUD use case for any entity type, enforcing the domain rules (validation, key generation,
/// uniqueness). One generic implementation replaces the former per-type use case classes.
class ManageEntitiesUseCase(T) : IManageEntities!T {
  private IRepository!T _repository;

  this(IRepository!T repository) {
    _repository = repository;
  }

  T[] list() {
    return _repository.findAll();
  }

  T get(string id) {
    T entity;
    if (!_repository.tryFind(id, entity))
      throw new EntityNotFoundException(T.stringof, id);
    return entity;
  }

  bool exists(string id) {
    return _repository.exists(id);
  }

  size_t count() {
    return _repository.count();
  }

  T create(T entity) {
    if (entity.ID.length == 0)
      entity.ID = nextBusinessId(T.idPrefix, _repository.findAll().map!(e => e.ID).array, is(T == User) ? 3 : 2);
    if (_repository.exists(entity.ID))
      throw new ConflictException(T.stringof ~ " '" ~ entity.ID ~ "' already exists");
    validate(entity);
    _repository.save(entity);
    return entity;
  }

  T replace(string id, T entity) {
    get(id); // must exist
    entity.ID = id;
    validate(entity);
    _repository.save(entity);
    return entity;
  }

  T modify(string id, scope void delegate(ref T entity) @safe change) {
    auto entity = get(id);
    change(entity);
    entity.ID = id; // the key is immutable
    validate(entity);
    _repository.save(entity);
    return entity;
  }

  void remove(string id) {
    if (!_repository.remove(id))
      throw new EntityNotFoundException(T.stringof, id);
  }

  void replaceAll(T[] entities) {
    bool[string] seen;
    foreach (ref entity; entities) {
      validate(entity);
      if (entity.ID in seen)
        throw new ConflictException("Duplicate " ~ T.stringof ~ " '" ~ entity.ID ~ "'");
      seen[entity.ID] = true;
    }
    _repository.replaceAll(entities);
  }
}

///
unittest {
  import uim.fiori_blocks.persistence;

  auto useCase = new ManageEntitiesUseCase!InterfaceBlock(
    new DocumentRepository!InterfaceBlock(new MemoryDocumentStorage, "InterfaceBlocks", seedInterfaceBlocks));

  auto created = useCase.create(InterfaceBlock("", "GraphQL"));
  assert(created.ID == "IF-03");

  auto changed = useCase.modify("IF-03", (ref InterfaceBlock b) { b.Status = "Active"; b.ID = "HACK"; });
  assert(changed.ID == "IF-03" && useCase.get("IF-03").Status == "Active");

  bool conflict, notFound, invalid;
  try
    useCase.create(InterfaceBlock("IF-01", "Duplicate"));
  catch (ConflictException)
    conflict = true;
  try
    useCase.remove("IF-99");
  catch (EntityNotFoundException)
    notFound = true;
  try
    useCase.replace("IF-01", InterfaceBlock("", ""));
  catch (ValidationException)
    invalid = true;
  assert(conflict && notFound && invalid);
}
