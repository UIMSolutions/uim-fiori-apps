/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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