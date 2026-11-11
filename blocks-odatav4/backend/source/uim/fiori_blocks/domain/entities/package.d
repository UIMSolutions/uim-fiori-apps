/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.domain.entities;

/// Business objects with their own identity.
/// Entities are plain structs without any framework dependency (no Json, no vibe.d).
/// Serialization is handled by the generic codec in `infrastructure.serialization`.
public:
  import uim.fiori_blocks.domain.entities.dependency;
  import uim.fiori_blocks.domain.entities.base;
  import uim.fiori_blocks.domain.entities.architecture;
  import uim.fiori_blocks.domain.entities.solution;
  import uim.fiori_blocks.domain.entities.interface_;
  import uim.fiori_blocks.domain.entities.user;

/// Compile-time list of all entity types that are exposed as entity sets.
import std.meta : AliasSeq;

alias AllEntities = AliasSeq!(BaseBlock, ArchitectureBlock, SolutionBlock, InterfaceBlock, User);

/// True if `T` is an entity: a struct with a string `ID` key.
enum isEntity(T) = is(T == struct) && is(typeof(T.init.ID) == string);

static foreach (E; AllEntities) {
  static assert(isEntity!E, E.stringof ~ " must be a struct with a string ID");
}
