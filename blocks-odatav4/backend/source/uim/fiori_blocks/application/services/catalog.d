/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.application.services.catalog;

/// Type-erased access to all entity sets.
///
/// Every presentation adapter (OData, CLI, GUI) works with the `ServiceCatalog`: it addresses
/// entity sets by name and exchanges Json DTOs, while the typed use cases enforce the business rules.
import std.algorithm : map;
import std.array : array;

import vibe.data.json : Json;

import uim.fiori_blocks.application.dtos;
import uim.fiori_blocks.application.services.query;
import uim.fiori_blocks.domain.exceptions;
import uim.fiori_blocks.infrastructure.serialization : decode, encode, merge;
import uim.fiori_blocks.ports.usecases;

@safe:

interface IEntitySetService {
  string name() const;
  string typeName() const;
  string keyProperty() const;
  const(PropertyInfo)[] properties() const;
  const(TypeInfo_)[] complexTypes() const;

  Json[] list();
  QueryResult query(const ref QuerySpec spec);
  Json get(string id);
  bool exists(string id);
  size_t count();
  Json create(Json data);
  Json patch(string id, Json data);
  Json replace(string id, Json data);
  void remove(string id);
  /// Replaces all entities (import). Validates everything before changing anything.
  void importAll(Json[] data);

  /// Snapshot / restore for transactional changesets ($batch).
  Json[] snapshot();
  void restore(Json[] data);
}

class EntitySetService(T) : IEntitySetService {
  private IManageEntities!T _useCase;
  private static immutable PropertyInfo[] _properties = propertiesOf!T;
  private static immutable TypeInfo_[] _complexTypes = complexTypesOf!T;

  this(IManageEntities!T useCase) {
    _useCase = useCase;
  }

  string name() const {
    return T.entitySet;
  }

  string typeName() const {
    return T.stringof;
  }

  string keyProperty() const {
    return "ID";
  }

  const(PropertyInfo)[] properties() const {
    return _properties;
  }

  const(TypeInfo_)[] complexTypes() const {
    return _complexTypes;
  }

  Json[] list() {
    return _useCase.list().map!(e => encode(e)).array;
  }

  QueryResult query(const ref QuerySpec spec) {
    return runQuery(list(), spec, keyProperty);
  }

  Json get(string id) {
    return encode(_useCase.get(id));
  }

  bool exists(string id) {
    return _useCase.exists(id);
  }

  size_t count() {
    return _useCase.count();
  }

  Json create(Json data) {
    return encode(_useCase.create(decode!T(data)));
  }

  Json patch(string id, Json data) {
    return encode(_useCase.modify(id, (ref T entity) { merge(entity, data); }));
  }

  Json replace(string id, Json data) {
    return encode(_useCase.replace(id, decode!T(data)));
  }

  void remove(string id) {
    _useCase.remove(id);
  }

  void importAll(Json[] data) {
    _useCase.replaceAll(data.map!(d => decode!T(d)).array);
  }

  Json[] snapshot() {
    return list();
  }

  void restore(Json[] data) {
    importAll(data);
  }
}

/// Registry of all entity sets, in registration order.
class ServiceCatalog {
  private IEntitySetService[string] _byName;
  private IEntitySetService[] _ordered;

  ServiceCatalog register(IEntitySetService service) {
    if (service.name in _byName)
      throw new Exception("Entity set registered twice: " ~ service.name);
    _byName[service.name] = service;
    _ordered ~= service;
    return this;
  }

  IEntitySetService[] all() {
    return _ordered;
  }

  string[] names() {
    return _ordered.map!(s => s.name).array;
  }

  /// Returns null if the entity set does not exist.
  IEntitySetService find(string name) {
    auto found = name in _byName;
    return found is null ? null : *found;
  }

  /// Throws `EntityNotFoundException` if the entity set does not exist.
  IEntitySetService opIndex(string name) {
    auto service = find(name);
    if (service is null)
      throw new EntityNotFoundException("EntitySet", name);
    return service;
  }

  /// Runs `work` atomically across all entity sets: on any exception every set is restored.
  void transaction(scope void delegate() @safe work) {
    Json[][string] backup;
    foreach (service; _ordered)
      backup[service.name] = service.snapshot();
    try {
      work();
    } catch (Exception e) {
      foreach (service; _ordered)
        service.restore(backup[service.name]);
      throw e;
    }
  }
}
