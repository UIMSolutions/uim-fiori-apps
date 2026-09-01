module domain;

import uim.fiori;
@safe:
/// Entitätsdefinition für die Adressverwaltung
struct Address {
    @ODataKey 
    string Id;
    
    string FirstName;
    string LastName;
    string Street;
    string City;
    string PostalCode;
    string Country;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["Id"] = Id;
        j["FirstName"] = FirstName;
        j["LastName"] = LastName;
        j["Street"] = Street;
        j["City"] = City;
        j["PostalCode"] = PostalCode;
        j["Country"] = Country;
        return j;
    }
}