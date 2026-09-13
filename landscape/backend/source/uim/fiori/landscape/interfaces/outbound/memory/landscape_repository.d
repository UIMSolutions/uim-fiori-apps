module uim.fiori.landscape.interfaces.outbound.memory.landscape_repository;
import uim.fiori.landscape.domain.entities;
import uim.fiori.landscape.domain.ports;
class InMemoryLandscapeRepository : LandscapeReadPort {
private:
    ITSystem[] _systems;
    InterfaceLink[] _interfaces;
    BusinessArea[] _areas;
    ProcessLevel[] _levels;
public:
    this() {
        seed();
    }
    override ITSystem[] listSystems() {
        return _systems.dup;
    }
    override ITSystem findSystemById(string id) {
        foreach (entry; _systems) {
            if (entry.id == id) {
                return entry;
            }
        }
        return ITSystem.init;
    }
    override InterfaceLink[] listInterfaces() {
        return _interfaces.dup;
    }
    override BusinessArea[] listBusinessAreas() {
        return _areas.dup;
    }
    override ProcessLevel[] listProcessLevels() {
        return _levels.dup;
    }
private:
    void seed() {
        _areas = [
            BusinessArea("ba-1", "Einkauf", 1),
            BusinessArea("ba-2", "Vertrieb", 2),
            BusinessArea("ba-3", "HR", 3),
            BusinessArea("ba-4", "Finanzen", 4)
        ];
        _levels = [
            ProcessLevel("pl-1", "Strategisch", 1),
            ProcessLevel("pl-2", "Kernprozess", 2),
            ProcessLevel("pl-3", "Support", 3)
        ];
        _systems = [
            ITSystem(
                "sys-s4",
                "SAP S/4HANA",
                "Finanzen",
                "Kernprozess",
                "Active",
                "On-Premise",
                "Tier 1",
                "Success",
                "CFO Office",
                "ERP Team",
                "Core ERP"
            ),
            ITSystem(
                "sys-sf",
                "SAP SuccessFactors",
                "HR",
                "Kernprozess",
                "Active",
                "Cloud",
                "Tier 1",
                "Success",
                "HR Director",
                "HXM Team",
                "HCM Suite"
            ),
            ITSystem(
                "sys-ariba",
                "SAP Ariba",
                "Einkauf",
                "Kernprozess",
                "Active",
                "Cloud",
                "Tier 2",
                "Information",
                "Head of Procurement",
                "Source-to-Pay Team",
                "Supplier network"
            ),
            ITSystem(
                "sys-crm",
                "Legacy CRM",
                "Vertrieb",
                "Support",
                "Decommissioning",
                "On-Premise",
                "Tier 2",
                "Warning",
                "Sales Ops",
                "CRM Team",
                "Old customer management"
            ),
            ITSystem(
                "sys-bi",
                "BW Reporting",
                "Finanzen",
                "Strategisch",
                "Redundant",
                "On-Premise",
                "Tier 3",
                "Error",
                "Controlling",
                "BI Team",
                "Legacy reporting"
            )
        ];
        _interfaces = [
            InterfaceLink("if-1", "sys-s4", "sys-sf", "IDoc", "Outbound", "MasterData"),
            InterfaceLink("if-2", "sys-ariba", "sys-s4", "REST", "Inbound", "Procurement"),
            InterfaceLink("if-3", "sys-crm", "sys-s4", "RFC", "Outbound", "Orders"),
            InterfaceLink("if-4", "sys-s4", "sys-bi", "ODP", "Outbound", "Analytics"),
            InterfaceLink("if-5", "sys-bi", "sys-crm", "Batch", "Inbound", "Reporting")
        ];
    }
}
