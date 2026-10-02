module uim.fiori.manifest.configs.ui5;

import uim.fiori;
import uim.fiori.manifest.configs.config;

@safe:

struct SapUi5Config {
    string resources; /// The resources used by the UI5 configuration.
    string dependencies; /// The dependencies in the UI5 configuration.
    string componentUsages; /// The component usages in the UI5 configuration.
    Model[string] models; /// The models in the UI5 configuration.
    string rootView; /// The root view of the UI5 configuration.
    string autoPrefixId; /// Indicates whether auto prefix ID is enabled.
    string handleValidation; /// Indicates whether validation handling is enabled.
    string config; /// The configuration settings for the UI5 application.
    string routing; /// The routing configuration for the UI5 application.
    string extends; /// The base configuration that this configuration extends.
    string contentDensities; /// The content densities supported by the UI5 application.
    string resourceRoots; /// The resource roots for the UI5 application.
    string componentName; /// The name of the component.
    string library; /// The library associated with the UI5 configuration.
    string flexEnabled; /// Indicates whether flexibility features are enabled.
    string commands; /// Specifies provided commands with a unique key/alias.
    string flexExtensionPointEnabled; /// Indicates whether the flex extension point is enabled.
}

