module main;
import uim.fiori;
import std.process : environment;
@safe:
struct Person {
    int ID;
    string Name;
    string Email;
    string Role;
}
class PersonODataService {
    private Person[] persons;
    private int nextId = 1;
    this() {
        persons = [
            Person(nextId++, "Erika Mustermann", "erika@example.com", "Developer"),
            Person(nextId++, "Max Mustermann", "max@example.com", "Manager")
        ];
    }
    // GET /odata/v4/$metadata (Service Metadata Dokument)
    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
		writeln("Handling GET /odata/v4/$metadata request: ", req.method, " ", req.requestURL);
        string xmlMetadata = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
    <edmx:DataServices>
        <Schema Namespace="PersonService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
            <EntityType Name="Person">
                <Key>
                    <PropertyRef Name="ID" />
                </Key>
                <Property Name="ID" Type="Edm.Int32" Nullable="false" />
                <Property Name="Name" Type="Edm.String" />
                <Property Name="Email" Type="Edm.String" />
                <Property Name="Role" Type="Edm.String" />
            </EntityType>
            <EntityContainer Name="EntityContainer">
                <EntitySet Name="Persons" EntityType="PersonService.Person" />
            </EntityContainer>
        </Schema>
    </edmx:DataServices>
</edmx:Edmx>`;
        res.contentType = "application/xml";
        res.writeBody(xmlMetadata);
    }
    // GET /odata/v4/Persons (EntitySet abfragen)
    void getPersons(HTTPServerRequest req, HTTPServerResponse res) {
		writeln("Handling GET /odata/v4/Persons request: ", req.method, " ", req.requestURL);
        Json responseJson = Json.emptyObject;
        responseJson["@odata.context"] = "$metadata#Persons";
        
        Json list = Json.emptyArray;
        foreach (p; persons) {
            list ~= Json.emptyObject
            .set("ID", p.ID)
            .set("Name", p.Name)
            .set("Email", p.Email)
            .set("Role", p.Role);
        }
        responseJson["value"] = list;
        res.writeODataJson(responseJson);
    }
    // POST /odata/v4/Persons (Neue Entity anlegen)
    void createPerson(HTTPServerRequest req, HTTPServerResponse res) {
		writeln("Handling POST /odata/v4/Persons request: ", req.method, " ", req.requestURL);
		writeln("Request Body: ", req.json);
        auto bodyJson = req.json;
        
        Person newPerson;
        newPerson.ID = nextId++;
        newPerson.Name = bodyJson["Name"].get!string;
        newPerson.Email = bodyJson["Email"].get!string;
        newPerson.Role = bodyJson.hasKey("Role") ? bodyJson["Role"].get!string : "";
        
        persons ~= newPerson;
        Json createdJson = Json.emptyObject;
        createdJson["@odata.context"] = "$metadata#Persons/$entity";
        createdJson["ID"] = newPerson.ID;
        createdJson["Name"] = newPerson.Name;
        createdJson["Email"] = newPerson.Email;
        createdJson["Role"] = newPerson.Role;
        res.statusCode = 201; // Created
        res.writeODataJson(createdJson);
    }
    // DELETE /odata/v4/Persons(1) (Entity löschen)
    void deletePerson(HTTPServerRequest req, HTTPServerResponse res) {
        writeln("Handling DELETE /odata/v4/Persons request: ", req.method, " ", req.requestURL);
		auto path = req.requestPath.toString();
		writeln("Request Path: ", path);
		if (!path.contains("(") || !path.contains(")")) {
			res.statusCode = 400; // Bad Request
			res.writeODataJson(["error": ["code": "400", "message": "Ungültige URL"]]);
			return;
		}
		auto items = path.split("(");
		if (items.length != 2) {
			res.statusCode = 400; // Bad Request	
			res.writeODataJson(["error": ["code": "400", "message": "Ungültige URL"]]);
			return;
		}
		auto strId = items[1].split(")")[0]; // Extrahiere die ID aus der URL		
		writeln("Extracted ID from URL: ", strId);
		int id;
		try {
			id = to!int(strId);
		} catch (Exception e) {
			res.statusCode = 400; // Bad Request
			res.writeODataJson(["error": ["code": "400", "message": "Ungültige ID"]]);
			return;
		}
		if (persons.any!(p => p.ID == id)) {
			persons = persons.filter!(p => p.ID != id).array;
			writeln("Deleted Person with ID: ", id);
			writeln("Remaining Persons: ", persons);
			res.statusCode = 204; // No Content
			res.writeJsonBody(Json.emptyObject);
		} else {
			res.statusCode = 404; // Not Found
			res.writeODataJson(["error": ["code": "404", "message": "Person nicht gefunden"]]);
		}
	}
}
void main() {
    auto settings = new HTTPServerSettings;
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];    
	// settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;
    auto service = new PersonODataService();
	// CORS Middleware
	router.any("*", &handleCORS);
    // OData V4 Routen registrieren
    router.get("/odata/v4/$metadata", &service.getMetadata);
    router.get("/odata/v4/Persons", &service.getPersons);
    router.post("/odata/v4/Persons", &service.createPerson);
    router.delete_("/odata/v4/Persons*", &service.deletePerson);
    // Static Frontend Files
    router.get("*", serveStaticFiles("public/"));
    listenHTTP(settings, router);
	runApplication();
}
