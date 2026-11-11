/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports;

/// Ports: the interfaces between the application core and the adapters.
/// - driving ports (usecases): called by presentation adapters (OData, CLI, GUI)
/// - driven ports (repositories, storages, services): implemented by persistence / infrastructure
public:
  import uim.fiori_blocks.ports.repositories;
  import uim.fiori_blocks.ports.services;
  import uim.fiori_blocks.ports.storages;
  import uim.fiori_blocks.ports.usecases;
