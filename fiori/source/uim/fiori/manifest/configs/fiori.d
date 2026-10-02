module uim.fiori.manifest.configs.fiori;

import uim.fiori;
import uim.fiori.manifest.configs.config;
@safe:

struct SapFioriConfig {
    string[] registrationIds; // Represents array of registration ids, i.e. for Fiori apps fiori id(s)
    string archeType; // Represents architecture type of an application. Valid values are "transactional",
        // "analytical", "factsheet", "reusecomponent", "fpmwebdynpro", "designstudio"                    
    // Optional attributes
    string version_; // Represents attributes format version.
    bool isAbstract; // Indicator that app is an abstract (generic) app which may not be used directly, but needs to be specialized in the SAP Fiori launchpad content
    CloudDevAdaptationStatus cloudDevAdaptationStatus; // Represents the cloud development adaptation status of the application.

    Json toJson() const {
        Json result = Json.emptyObject;
        // Required attributes
        result["registrationIds"] = registrationIds.toJson();
        result["archeType"] = archeType;
        // Optional attributes
        if (!version_.isEmpty) result["_version"] = version_;
        if (isAbstract) result["isAbstract"] = isAbstract;
        if (cloudDevAdaptationStatus != CloudDevAdaptationStatus.released) result["cloudDevAdaptationStatus"] = cloudDevAdaptationStatus;
        return result;
    }
}
