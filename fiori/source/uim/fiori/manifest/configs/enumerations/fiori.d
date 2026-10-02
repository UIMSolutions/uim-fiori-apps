module uim.fiori.manifest.configs.enumerations.fiori;

import uim.fiori;

@safe:

enum ArcheType {
    transactional,
    analytical,
    factsheet,
    reusecomponent,
    fpmwebdynpro,
    designstudio
}

string toString(ArcheType archeType) {
    switch (archeType) {
        case ArcheType.transactional: return "transactional";
        case ArcheType.analytical: return "analytical";
        case ArcheType.factsheet: return "factsheet";
        case ArcheType.reusecomponent: return "reusecomponent";
        case ArcheType.fpmwebdynpro: return "fpmwebdynpro";
        case ArcheType.designstudio: return "designstudio";
        default: return "";
    }
}

ArcheType fromString(string value) {
    switch(value) {
        case "transactional": return ArcheType.transactional;
        case "analytical": return ArcheType.analytical;
        case "factsheet": return ArcheType.factsheet;
        case "reusecomponent": return ArcheType.reusecomponent;
        case "fpmwebdynpro": return ArcheType.fpmwebdynpro;
        case "designstudio": return ArcheType.designstudio;
        default: return ArcheType.transactional; // Default value
    }
}

enum CloudDevAdaptationStatus {
    none,
    released,
    deprecated_,
    obsolete
}

string toString(CloudDevAdaptationStatus status) {
    switch (status) {
        case CloudDevAdaptationStatus.released: return "released";
        case CloudDevAdaptationStatus.deprecated_: return "deprecated";
        case CloudDevAdaptationStatus.obsolete: return "obsolete";
        default: return "";
    }
}

CloudDevAdaptationStatus toCloudDevAdaptationStatus(string value) {
    switch(value) {
        case "released": return CloudDevAdaptationStatus.released;
        case "deprecated": return CloudDevAdaptationStatus.deprecated_;
        case "obsolete": return CloudDevAdaptationStatus.obsolete;
        default: return CloudDevAdaptationStatus.none; // Default value
    }
}

