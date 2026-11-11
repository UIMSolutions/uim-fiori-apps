/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks;

/// EA building blocks manager: hexagonal architecture with OData v4, HTTP, CLI and GtkD adapters.
///
/// Dependency direction: presentation -> application -> domain <- persistence/infrastructure
/// (ports define the boundaries, `composition` wires the implementations).
public:
  import uim.fiori_blocks.domain;
  import uim.fiori_blocks.ports;
  import uim.fiori_blocks.application;
  import uim.fiori_blocks.infrastructure;
  import uim.fiori_blocks.persistence;
  import uim.fiori_blocks.presentation;
  import uim.fiori_blocks.composition;
