module uim.fiori_blocks.infrastructure.repositories.base;

import uim.fiori_blocks;

@safe:

class BaseRepository : BlockRepository!BaseBlock {
    this() {
        _blocks["SB-01"] = BaseBlock("BB-01", "SAP S/4HANA Finance", "Finance Base", "1.0", "2024-01-01", "S/4HANA", [
            "Dies und jenes"
        ], [
                Dependency("SB-02", "SAP S/4HANA Sales", "REST API Call", "High"),
                Dependency("SB-03", "SAP S/4HANA Procurement", "REST API Call", "Medium")
            ]);
        _blocks["SB-02"] = BaseBlock("SB-02", "SAP S/4HANA Sales", "Sales Base", "1.0", "2024-01-01", "S/4HANA", [
            ]);

    }
}
///
unittest {
    import uim.fiori_blocks.infrastructure.repositories.solution;

    auto repo = new BaseRepository();
    auto block1 = BaseBlock("BB-01", "SAP S/4HANA Finance", "Finance Base", "Haupt-ERP Finanzmodul", "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Max Mustermann", [
                Dependency("SB-02", "SAP S/4HANA Sales", "REST API Call", "High"),
                Dependency("SB-03", "SAP S/4HANA Procurement", "REST API Call", "Medium")
            ]);
    auto block2 = BaseBlock("SB-02", "SAP S/4HANA Sales", "Sales Base", "Haupt-ERP Vertriebsmodul", "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Jane Doe", [
            ]);

    repo.save(block1);
    repo.save(block2);
    
    void testBaseRepository() {
        assert(repo.exists("SB-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testBaseRepositoryList() {
        auto allBlocks = repo.findAll();
        assert(allBlocks.length > 0);
    }

    void testBaseRepositoryHasBlock() {
        assert(repo.exists("SB-01"));
        assert(!repo.exists("NON-EXISTENT"));
    }

    void testBaseRepositoryHasAllBlocks() {
        assert(repo.existsAll(["SB-01", "SB-02"]));
        assert(!repo.existsAll(["SB-01", "NON-EXISTENT"]));
    }

    void testBaseRepositoryHasAnyBlock() {
        assert(repo.existsAny(["SB-01", "NON-EXISTENT"]));
        assert(!repo.existsAny(["NON-EXISTENT", "ANOTHER-NON-EXISTENT"]));
    }

    void testBaseRepositoryGetBlock() {
        auto block = repo.find("SB-01");
        assert(!block.isNull);
        auto nonExistentBlock = repo.find("NON-EXISTENT");
        assert(nonExistentBlock.isNull);
    }

    void testBaseRepositoryDeleteBlock() {
        assert(repo.exists("SB-02"));
        repo.remove("SB-02");
        assert(!repo.exists("SB-02"));
    }

    void testBaseRepositoryAddBlock() {
        auto newBlock = BaseBlock("SB-03", "SAP S/4HANA Procurement", "Procurement Base", "Haupt-ERP Beschaffungsmodul", "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "John Doe", [
            ]);
        repo.save(newBlock);
        assert(repo.exists("SB-03"));
    }

    void testAll() {
        testBaseRepository();
        testBaseRepositoryList();
        testBaseRepositoryHasBlock();
        testBaseRepositoryHasAllBlocks();
        testBaseRepositoryHasAnyBlock();
        testBaseRepositoryGetBlock();
        testBaseRepositoryDeleteBlock();
        testBaseRepositoryAddBlock();
    }

    testAll();
}

