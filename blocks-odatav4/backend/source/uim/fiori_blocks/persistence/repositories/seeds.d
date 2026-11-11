/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.persistence.repositories.seeds;

/// Initial demo data, used when a collection has never been stored.
import uim.fiori_blocks.domain.entities;

@safe:

BaseBlock[] seedBaseBlocks() pure {
  return [
    BaseBlock("BB-01", "SAP S/4HANA Finance", "Finance Base", "1.0", "2024-01-01", "S/4HANA",
      ["Dies und jenes"], [
        Dependency("BB-02", "SAP S/4HANA Sales", "REST API Call", "High"),
        Dependency("BB-03", "SAP S/4HANA Procurement", "REST API Call", "Medium")
      ]),
    BaseBlock("BB-02", "SAP S/4HANA Sales", "Sales Base", "1.0", "2024-01-01", "S/4HANA")
  ];
}

ArchitectureBlock[] seedArchitectureBlocks() pure {
  return [
    ArchitectureBlock("AB-01", "Domain Model Core", "Max Mustermann", "1.0.0", "Core-Domain",
      "Domain Service", "Enterprise Core", "2026-09-21", "Zentrales Domänenmodell für Kernprozesse",
      "Enthält Entitäten und Value Objects", [
        Dependency("AB-02", "Extended Architecture", "REST API Call", "High"),
        Dependency("AB-05", "Event Bus / Kafka", "Async Messaging", "Medium")
      ]),
    ArchitectureBlock("AB-02", "Extended Architecture", "Jane Smith", "2.0", "ExtendedModule",
      "ExtendedService", "ExtendedProduct", "2024-06-02", "Description of extended architecture",
      "Additional info", [
        Dependency("AB-01", "Domain Model Core", "REST API Call", "High"),
        Dependency("AB-03", "Another Dependency", "Async Messaging", "Medium")
      ])
  ];
}

SolutionBlock[] seedSolutionBlocks() pure {
  return [
    SolutionBlock("SB-01", "SAP S/4HANA Finance", "Finance Solution", "Haupt-ERP Finanzmodul",
      "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Max Mustermann", [
        Dependency("SB-02", "SAP S/4HANA Sales", "REST API Call", "High"),
        Dependency("SB-03", "SAP S/4HANA Procurement", "REST API Call", "Medium")
      ]),
    SolutionBlock("SB-02", "SAP S/4HANA Sales", "Sales Solution", "Haupt-ERP Vertriebsmodul",
      "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Jane Doe")
  ];
}

InterfaceBlock[] seedInterfaceBlocks() pure {
  return [
    InterfaceBlock("IF-01", "REST/OData API v4", "Interface", "Schnittstelle zwischen vibe.d und Fiori", "In Progress"),
    InterfaceBlock("IF-02", "SOAP API", "Interface", "Schnittstelle für SOAP-basierte Kommunikation", "In Progress")
  ];
}

User[] seedUsers() pure {
  return [
    User("USR-001", "admin", "admin@example.com", "Administrator", true),
    User("USR-002", "editor", "editor@example.com", "Editor", true),
    User("USR-003", "viewer", "viewer@example.com", "Viewer", false)
  ];
}

/// Seed data by entity type (used by the composition root).
T[] seedFor(T)() pure {
  static if (is(T == BaseBlock))
    return seedBaseBlocks();
  else static if (is(T == ArchitectureBlock))
    return seedArchitectureBlocks();
  else static if (is(T == SolutionBlock))
    return seedSolutionBlocks();
  else static if (is(T == InterfaceBlock))
    return seedInterfaceBlocks();
  else static if (is(T == User))
    return seedUsers();
  else
    return null;
}
