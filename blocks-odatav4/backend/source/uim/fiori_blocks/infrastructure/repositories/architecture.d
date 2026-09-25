/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
///
unittest {
    import uim.fiori_blocks.infrastructure.repositories.architecture;

    auto repo = new ArchitectureRepository();
    auto block1 = ArchitectureBlock(
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
    auto block2 = ArchitectureBlock("ARCH-02", "Extended Architecture", "Jane Smith", "2.0", "ExtendedModule", "ExtendedService", "ExtendedProduct", "2024-06-02", "Description of extended architecture", "Additional info", [
            Dependency("AB-01", "Domain Model Core", "REST API Call", "High"),
            Dependency("AB-03", "Another Dependency", "Async Messaging", "Medium")
        ]);
    repo.save(block1);
    repo.save(block2);
    
    void testArchitectureRepository() {
        assert(repo.exists("AB-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testArchitectureRepositoryList() {
        auto allBlocks = repo.findAll();
        assert(allBlocks.length > 0);
    }

    void testArchitectureRepositoryHasBlock() {
        assert(repo.exists("AB-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testArchitectureRepositoryHasAllBlocks() {
        assert(repo.existsAll(["AB-01", "ARCH-02"]));
        assert(!repo.existsAll(["AB-01", "NON-EXISTENT"]));
    }

    void testArchitectureRepositoryHasAnyBlock() {
        assert(repo.existsAny(["AB-01", "NON-EXISTENT"]));
        assert(!repo.existsAny(["NON-EXISTENT", "ANOTHER-NON-EXISTENT"]));
    }

    void testArchitectureRepositoryGetBlock() {
        auto block = repo.find("AB-01");
        assert(!block.isNull);
        auto nonExistentBlock = repo.find("NON-EXISTENT");
        assert(nonExistentBlock.isNull);
    }

    void testArchitectureRepositoryDeleteBlock() {
        assert(repo.exists("ARCH-02"));
        repo.remove("ARCH-02");
        assert(!repo.exists("ARCH-02"));
    }

    void testArchitectureRepositoryAddBlock() {
        auto newBlock = ArchitectureBlock(
            "ARCH-03",
            "New Architecture Block",
            "John Doe",
            "1.0",
            "NewModule",
            "NewService",
            "NewProduct",
            "2024-06-02",
            "Description of new architecture block",
            "Additional info",
            [
                Dependency("AB-01", "Domain Model Core", "REST API Call", "High")
            ]
        );
        repo.save(newBlock);
        assert(repo.exists("ARCH-03"));
    }

    void testAll() {
        testArchitectureRepository();
        testArchitectureRepositoryList();
        testArchitectureRepositoryHasBlock();
        testArchitectureRepositoryHasAllBlocks();
        testArchitectureRepositoryHasAnyBlock();
        testArchitectureRepositoryGetBlock();
        testArchitectureRepositoryDeleteBlock();
        testArchitectureRepositoryAddBlock();
    }

    testAll();
}
