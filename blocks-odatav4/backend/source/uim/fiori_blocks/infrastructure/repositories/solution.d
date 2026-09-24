module uim.fiori_blocks.infrastructure.repositories.solution;

import uim.fiori_blocks;

@safe:

class SolutionRepository : BlockRepository!SolutionBlock {
    this() {
        _blocks["SB-01"] = SolutionBlock("SB-01", "SAP S/4HANA Finance", "Finance Solution", "Haupt-ERP Finanzmodul", "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Max Mustermann", [
                Dependency("SB-02", "SAP S/4HANA Sales", "REST API Call", "High"),
                Dependency("SB-03", "SAP S/4HANA Procurement", "REST API Call", "Medium")
            ]);
        _blocks["SB-02"] = SolutionBlock("SB-02", "SAP S/4HANA Sales", "Sales Solution", "Haupt-ERP Vertriebsmodul", "2024-01-01", "2026-12-31", "1.0", "2024-01-01", "Zusätzliche Informationen", "Jane Doe", [
            ]);

    }
}
