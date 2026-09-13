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
    /// The property in the referenced entity that this foreign key points to.
    string referencedProperty = "Id";
}
/// Marking a property as a navigation property in an OData entity.
struct ODataNavigation {
    /// The target entity set for the navigation property.
    string targetEntitySet;
    /// The target property in the target entity set that this navigation property refers to.
    string targetProperty = "Id";
    
    /// Optional navigation partner property.
    string partner = "";              
    /// Indicates if the navigation property contains the target entity (composition).
    bool containsTarget = false;      
}
/// Marking a property as a navigation property in an OData entity with additional metadata.
struct ODataNavigationProperty {
    /// Optional navigation partner property.
    string partner = ""; 
    /// Indicates if the navigation property contains the target entity (composition).
    bool containsTarget = false;      
}
