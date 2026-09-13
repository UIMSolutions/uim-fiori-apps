module uim.fiori.landscape.application.landscape_service;
import std.algorithm.searching : canFind;
import std.array : join;
import std.string : toLower;
import uim.fiori.landscape.domain.entities;
import uim.fiori.landscape.domain.ports;
class LandscapeService {
private:
    LandscapeReadPort _port;
public:
    this(LandscapeReadPort port) {
        _port = port;
    }
    ITSystem[] listSystems() {
        return _port.listSystems();
    }
    ITSystem findSystemById(string id) {
        return _port.findSystemById(id);
    }
    InterfaceLink[] listInterfaces() {
        return _port.listInterfaces();
    }
    InterfaceLink[] listInterfacesForSystem(string systemId) {
        InterfaceLink[] result;
        foreach (link; _port.listInterfaces()) {
            if (link.sourceSystemId == systemId || link.targetSystemId == systemId) {
                result ~= link;
            }
        }
        return result;
    }
    BusinessArea[] listBusinessAreas() {
        return _port.listBusinessAreas();
    }
    ProcessLevel[] listProcessLevels() {
        return _port.listProcessLevels();
    }
    MatrixCell[] buildMatrixCells() {
        auto systems = _port.listSystems();
        auto areas = _port.listBusinessAreas();
        auto levels = _port.listProcessLevels();
        MatrixCell[] result;
        foreach (area; areas) {
            foreach (level; levels) {
                string[] names;
                foreach (system; systems) {
                    if (system.businessArea == area.name && system.processLevel == level.name) {
                        names ~= system.name;
                    }
                }
                result ~= MatrixCell(
                    area.id ~ "-" ~ level.id,
                    area.name,
                    level.name,
                    names.join(", "),
                    cast(int) names.length
                );
            }
        }
        return result;
    }
    KPIEntry[] buildKPIs() {
        auto systems = _port.listSystems();
        int active;
        int decommissioning;
        int redundant;
        foreach (system; systems) {
            auto status = system.lifecycleStatus.toLower();
            if (status == "active") {
                active++;
            }
            if (status == "decommissioning") {
                decommissioning++;
            }
            if (status == "redundant") {
                redundant++;
            }
        }
        return [
            KPIEntry("kpi-active", "Active Systems", active, "Success"),
            KPIEntry("kpi-decom", "Decommissioning", decommissioning, "Warning"),
            KPIEntry("kpi-redundant", "Redundant", redundant, "Error")
        ];
    }
    ITSystem[] filterSystems(
        string criticality,
        string operatingModel,
        string lifecycleStatus,
        string containsName
    ) {
        auto all = _port.listSystems();
        ITSystem[] result;
        foreach (entry; all) {
            if (criticality.length > 0 && entry.criticality != criticality) {
                continue;
            }
            if (operatingModel.length > 0 && entry.operatingModel != operatingModel) {
                continue;
            }
            if (lifecycleStatus.length > 0 && entry.lifecycleStatus != lifecycleStatus) {
                continue;
            }
            if (containsName.length > 0 && !entry.name.toLower().canFind(containsName.toLower())) {
                continue;
            }
            result ~= entry;
        }
        return result;
    }
}
