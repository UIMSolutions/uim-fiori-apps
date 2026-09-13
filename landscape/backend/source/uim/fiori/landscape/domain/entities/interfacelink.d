module uim.fiori.landscape.domain.entities.interfacelink;

import uim.fiori.landscape;

@safe:
struct InterfaceLink {
    string id;
    string sourceSystemId;
    string targetSystemId;
    string protocol;
    string direction;
    string classification;
}