module uim.fiori_blocks.infrastructure.repositories.interface_;

import uim.fiori_blocks;

@safe:

class InterfaceRepository : BlockRepository!InterfaceBlock {
    this() {
        _blocks["IF-02"] = InterfaceBlock("IF-02", "SOAP API", "Interface", "Schnittstelle für SOAP-basierte Kommunikation", "In Progress");
        _blocks["IF-01"] = InterfaceBlock("IF-01", "REST/OData API v4", "Interface", "Schnittstelle zwischen vibe.d und Fiori", "In Progress");
    }
}