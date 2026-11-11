/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.persistence.repositories;

/// Concrete repository implementations of `IRepository!T`.
public import uim.fiori_blocks.persistence.repositories.seeds;

import std.algorithm : map, sort;
import std.array : array;

import vibe.data.json : Json;

import uim.fiori_blocks.persistence.mappers;
import uim.fiori_blocks.ports.repositories;
import uim.fiori_blocks.ports.storages;

@safe:

/// Repository with an in-memory index and write-through to an `IDocumentStorage`.
/// On first start (collection never stored) it is filled with the given seed data.
class DocumentRepository(T) : IRepository!T {
  private T[string] _items;
  private IDocumentStorage _storage;
  private string _collection;

  this(IDocumentStorage storage, string collection, T[] seed = null) {
    _storage = storage;
    _collection = collection;

    Json[] records;
    if (_storage.load(_collection, records)) {
      foreach (record; records) {
        auto entity = fromRecord!T(record);
        _items[entity.ID] = entity;
      }
    } else {
      foreach (entity; seed)
        _items[entity.ID] = entity;
      flush();
    }
  }

  T[] findAll() {
    return _items.values.sort!((a, b) => a.ID < b.ID).array;
  }

  bool tryFind(string id, out T entity) {
    if (auto found = id in _items) {
      entity = *found;
      return true;
    }
    return false;
  }

  bool exists(string id) {
    return (id in _items) !is null;
  }

  size_t count() {
    return _items.length;
  }

  void save(T entity) {
    _items[entity.ID] = entity;
    flush();
  }

  bool remove(string id) {
    if (!exists(id))
      return false;
    _items.remove(id);
    flush();
    return true;
  }

  void replaceAll(T[] entities) {
    _items = null;
    foreach (entity; entities)
      _items[entity.ID] = entity;
    flush();
  }

  private void flush() {
    _storage.store(_collection, findAll().map!(e => toRecord(e)).array);
  }
}

///
unittest {
  import uim.fiori_blocks.domain.entities;
  import uim.fiori_blocks.persistence.storages;

  auto storage = new MemoryDocumentStorage;
  auto repo = new DocumentRepository!ArchitectureBlock(storage, "ArchitectureBlocks", seedArchitectureBlocks);
  assert(repo.exists("AB-01"));
  assert(repo.findAll[0].ID == "AB-01");

  repo.save(ArchitectureBlock("AB-03", "New"));
  assert(repo.remove("AB-02") && !repo.remove("AB-02"));

  // a second repository on the same storage sees the persisted state, not the seed
  auto reloaded = new DocumentRepository!ArchitectureBlock(storage, "ArchitectureBlocks", seedArchitectureBlocks);
  assert(reloaded.exists("AB-03") && !reloaded.exists("AB-02"));
  assert(reloaded.findAll.length == 2);
}
