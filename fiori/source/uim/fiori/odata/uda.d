module uim.fiori.odata.uda;

import uim.fiori;

@safe:

/// Marking a property as the primary key in an OData entity.
struct ODataKey {}

/// Marking a struct as an OData entity set.
struct ODataEntitySet {
    string name;
}

/// Marking a property to be ignored in OData metadata generation.
struct ODataIgnore {}

/// Marking a property as a foreign key in an OData entity.
struct ODataForeignKey {
    string referencedProperty = "Id";
}

/// Marking a property as a navigation property in an OData entity.
struct ODataNavigation {
    string targetEntitySet;
    string targetProperty = "Id";
    string partner = "";              // Optionale Gegenbeziehung (Partner)
    bool containsTarget = false;      // Falls es eine Composition ist
}

/// Marking a property as a navigation property in an OData entity with additional metadata.
struct ODataNavigationProperty {
    string partner = "";              // Optionale Gegenbeziehung (Partner)
    bool containsTarget = false;      // Falls es eine Composition ist
}

