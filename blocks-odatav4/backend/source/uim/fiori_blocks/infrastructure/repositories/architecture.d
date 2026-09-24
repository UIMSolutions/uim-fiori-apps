module uim.fiori_blocks.infrastructure.repositories.architecture;

import uim.fiori_blocks;

@safe:

class ArchitectureRepository : BlockRepository!ArchitectureBlock {
    this() {
        _blocks["AB-01"] = ArchitectureBlock(
            "AB-01",
            "Domain Model Core",
            "Max Mustermann",
            "1.0.0",
            "Core-Domain",
            "Domain Service",
            "Enterprise Core",
            "2026-09-21",
            "Zentrales Domänenmodell für Kernprozesse",
            "Enthält Entitäten und Value Objects",
            [
                Dependency("AB-02", "Integration Gateway", "REST API Call", "High"),
                Dependency("AB-05", "Event Bus / Kafka", "Async Messaging", "Medium")
            ]
        );
        _blocks["ARCH-02"] = ArchitectureBlock("ARCH-02", "Extended Architecture", "Jane Smith", "2.0", "ExtendedModule", "ExtendedService", "ExtendedProduct", "2024-06-02", "Description of extended architecture", "Additional info", [
                Dependency("AB-01", "Domain Model Core", "REST API Call", "High"),
                Dependency("AB-03", "Another Dependency", "Async Messaging", "Medium")
            ]);

    }
}
