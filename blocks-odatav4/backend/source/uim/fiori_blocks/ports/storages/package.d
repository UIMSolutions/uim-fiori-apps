/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.storages;

/// Driven port: low-level document store. A collection is a list of JSON documents.
/// Implemented by `persistence.storages` (memory, JSON files).
import vibe.data.json : Json;

@safe:

interface IDocumentStorage {
  /// Loads a collection. Returns false if the collection has never been stored.
  bool load(string collection, out Json[] documents);

  /// Stores (replaces) a collection.
  void store(string collection, Json[] documents);

  /// Human readable description, e.g. "file:/var/data".
  string describe() const;
}
