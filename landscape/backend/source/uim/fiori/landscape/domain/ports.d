module uim.fiori.landscape.domain.ports;
import uim.fiori.landscape.domain.entities;
interface LandscapeReadPort {
    ITSystem[] listSystems();
    ITSystem findSystemById(string id);
    InterfaceLink[] listInterfaces();
    BusinessArea[] listBusinessAreas();
    ProcessLevel[] listProcessLevels();
}
