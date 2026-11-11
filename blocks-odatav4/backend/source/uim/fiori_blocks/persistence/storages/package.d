/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.persistence.storages;

/// Document storages implementing `IDocumentStorage`.
import std.file : exists, isDir, mkdirRecurse, readText, rename, write;
import std.path : absolutePath, buildPath;

import vibe.data.json : Json, parseJsonString;

import uim.fiori_blocks.ports.storages;

@safe:

/// Volatile storage (data lives as long as the process; collections start "never stored").
class MemoryDocumentStorage : IDocumentStorage {
  private Json[][string] _collections;

  bool load(string collection, out Json[] documents) {
    if (auto docs = collection in _collections) {
      documents = (*docs).dup;
      return true;
    }
    return false;
  }

  void store(string collection, Json[] documents) {
    _collections[collection] = documents.dup;
  }

  string describe() const {
    return "memory";
  }
}

/// Persists every collection as pretty printed JSON file `<dir>/<collection>.json`.
/// Writes are atomic (temp file + rename), so the CLI, the GUI and the server can share a data directory.
class JsonFileDocumentStorage : IDocumentStorage {
  private string _dir;

  this(string directory) @trusted {
    _dir = directory.absolutePath;
    if (!_dir.exists)
      mkdirRecurse(_dir);
    else if (!_dir.isDir)
      throw new Exception("Data path is not a directory: " ~ _dir);
  }

  bool load(string collection, out Json[] documents) @trusted {
    auto file = pathOf(collection);
    if (!file.exists)
      return false;
    auto json = parseJsonString(readText(file), file);
    if (json.type != Json.Type.array)
      throw new Exception("Expected a JSON array in " ~ file);
    documents = json.get!(Json[]);
    return true;
  }

  void store(string collection, Json[] documents) @trusted {
    auto file = pathOf(collection);
    auto temp = file ~ ".tmp";
    write(temp, Json(documents).toPrettyString ~ "\n");
    rename(temp, file);
  }

  string describe() const {
    return "file:" ~ _dir;
  }

  private string pathOf(string collection) const {
    return buildPath(_dir, collection ~ ".json");
  }
}

///
@trusted unittest {
  import std.file : tempDir, rmdirRecurse;
  import std.uuid : randomUUID;

  auto dir = buildPath(tempDir, "blocks-storage-" ~ randomUUID.toString);
  scope (exit)
    rmdirRecurse(dir);

  IDocumentStorage storage = new JsonFileDocumentStorage(dir);
  Json[] docs;
  assert(!storage.load("Things", docs));
  storage.store("Things", [Json(["ID": Json("1")])]);
  assert(storage.load("Things", docs) && docs.length == 1 && docs[0]["ID"].get!string == "1");

  IDocumentStorage memory = new MemoryDocumentStorage;
  memory.store("Things", docs);
  assert(memory.load("Things", docs) && docs.length == 1);
}
