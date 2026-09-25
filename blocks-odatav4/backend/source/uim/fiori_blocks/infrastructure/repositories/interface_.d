/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.repositories.interface_;

import uim.fiori_blocks;

@safe:

class InterfaceRepository : BlockRepository!InterfaceBlock {
    this() {
        _blocks["IF-02"] = InterfaceBlock("IF-02", "SOAP API", "Interface", "Schnittstelle für SOAP-basierte Kommunikation", "In Progress");
        _blocks["IF-01"] = InterfaceBlock("IF-01", "REST/OData API v4", "Interface", "Schnittstelle zwischen vibe.d und Fiori", "In Progress");
    }
}
///
unittest {
    import uim.fiori_blocks.infrastructure.repositories.interface_;

    auto repo = new InterfaceRepository();
    auto block1 = InterfaceBlock(
        "IF-01", "REST/OData API v4", "Interface", "Schnittstelle zwischen vibe.d und Fiori", "In Progress"
    );
    auto block2 = InterfaceBlock("IF-02", "SOAP API", "Interface", "Schnittstelle für SOAP-basierte Kommunikation", "In Progress");
    repo.save(block1);
    repo.save(block2);
    
    void testInterfaceRepository() {
        assert(repo.exists("IF-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testInterfaceRepositoryList() {
        auto allBlocks = repo.findAll();
        assert(allBlocks.length > 0);
    }

    void testInterfaceRepositoryHasBlock() {
        assert(repo.exists("IF-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testInterfaceRepositoryHasAllBlocks() {
        assert(repo.existsAll(["IF-01", "IF-02"]));
        assert(!repo.existsAll(["IF-01", "NON-EXISTENT"]));
    }

    void testInterfaceRepositoryHasAnyBlock() {
        assert(repo.existsAny(["IF-01", "NON-EXISTENT"]));
        assert(!repo.existsAny(["NON-EXISTENT", "ANOTHER-NON-EXISTENT"]));
    }

    void testInterfaceRepositoryGetBlock() {
        auto block = repo.find("IF-01");
        assert(!block.isNull);
        auto nonExistentBlock = repo.find("NON-EXISTENT");
        assert(nonExistentBlock.isNull);
    }

    void testInterfaceRepositoryDeleteBlock() {
        assert(repo.exists("IF-02"));
        repo.remove("IF-02");
        assert(!repo.exists("IF-02"));
    }

    void testInterfaceRepositoryAddBlock() {
        auto newBlock = InterfaceBlock("IF-03", "GraphQL API", "Interface", "Schnittstelle für GraphQL-basierte Kommunikation", "In Progress");
        repo.save(newBlock);
        assert(repo.exists("IF-03"));
    }

    void testAll() {
        testInterfaceRepository();
        testInterfaceRepositoryList();
        testInterfaceRepositoryHasBlock();
        testInterfaceRepositoryHasAllBlocks();
        testInterfaceRepositoryHasAnyBlock();
        testInterfaceRepositoryGetBlock();
        testInterfaceRepositoryDeleteBlock();
        testInterfaceRepositoryAddBlock();
    }

    testAll();
}