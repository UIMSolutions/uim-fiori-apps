module uim.fiori.manifest.configs.ui;

import uim.fiori;

@safe:

struct SapUiConfig {
    string technology; /// The technology used by the UI configuration.
    string icons; /// The icons used by the UI configuration.
    string deviceTypes; /// The device types supported by the UI configuration.
    bool fullWidth; /// Indicates whether the UI configuration should use the full width.

    Json toJson() const {
        auto json = Json.emptyObject;
        json["technology"] = technology;
        json["icons"] = icons;
        json["deviceTypes"] = deviceTypes;
        json["fullWidth"] = fullWidth;
        return json;
    }
}