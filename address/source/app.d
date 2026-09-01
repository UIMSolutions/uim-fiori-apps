module app;

// OData Library Imports
import uim.fiori;
import controller;
import domain;
import std.process;

/// In-Memory Provider mit CRUD-Logik
class AddressODataProvider : IODataProvider {
    private Json[string] store;

    this() {
        store["Addresses"] = Json.emptyArray;
        
        // Initial-Daten
        appendAddress(domain.Address("1001", "Max", "Mustermann", "Leopoldstraße 12", "München", "80802", "Deutschland"));
        appendAddress(domain.Address("1002", "Erika", "Musterfrau", "Hauptstraße 45", "Nürnberg", "90402", "Deutschland"));
    }

    private void appendAddress(domain.Address addr) {
        writeln("Adding address: ", addr.FirstName, " ", addr.LastName);
        writeln("Address: ", addr);
        store["Addresses"] ~= serializeToJson(addr);
    }

    override Json getEntitySet(string entitySetName, const ref ODataQueryOptions options) {
        writeln("Fetching entity set: ", entitySetName, " with options: ", options);

        return entitySetName in store ? applyQueryOptions(store[entitySetName], options) : Json.undefined;
    }

    override Json getEntity(string entitySetName, string key, const ref ODataQueryOptions options) {
        writeln("Fetching entity from ", entitySetName, " with key: ", key);

        if (entitySetName in store) {
            foreach (Json item; store.getArray(entitySetName)) {
                if (item.getString("Id") == key)
                    return item;
                
            }
        }
        return Json.undefined;
    }

    override Json createEntity(string entitySetName, Json payload) {
        writeln("Creating entity in ", entitySetName, ": ", payload);

        if (entitySetName == "Addresses") {
            if (payload.getString("Id").length == 0) {
                payload["Id"] = Clock.currTime.toUnixTime().to!string;
            }
            payload["@odata.context"] = "$metadata#Addresses/$entity";
            store["Addresses"].appendArrayElement(payload);
            return payload;
        }
        return Json.undefined;
    }
}

void main() {
    // 1. EDMX Metadaten generieren
    // string metadataXml = generateEdmx!("AddressService", Address)();

    // // 2. Provider & Router initialisieren
    // auto provider = new AddressODataProvider();
    // auto odataRouter = new ODataRouter(provider, metadataXml, ["Addresses"]);
    // auto odataRouter = new ODataRouter();

    auto router = new URLRouter;
    auto odataRouter = new ODataRouter();
    odataRouter.cachedMetadata = ODataMetadataGenerator.generateEdmx!("AddressService", domain.Address)();

    // 1. Controller instanziieren und für EntitySets registrieren
    auto addressCtrl = new AddressController();
    odataRouter.registerController("Addresses", addressCtrl);

	// CORS Middleware
	router.any("*", (HTTPServerRequest req, HTTPServerResponse res) {
		writeln("Handling CORS for request: ", req.method, " ", req.requestURL);

		res.headers["Access-Control-Allow-Origin"] = "*";
		res.headers["Access-Control-Allow-Methods"] = "GET, POST, DELETE, OPTIONS";
		res.headers["Access-Control-Allow-Headers"] = "Content-Type";
		if (req.method == HTTPMethod.OPTIONS) {
			res.writeBody("", 200);
			return;
		}
	});

    // 2. OData Routen unter /api/v4 anmelden
    odataRouter.registerRoutes(router, "/api/v4");

    // 3. Statische Dateien ganz zum Schluss
    router.get("*", serveStaticFiles("public/"));
    
    // 1. Controller instanziieren und für EntitySets registrieren
    // auto addressCtrl = new AddressController();
    // odataRouter.registerController("Addresses", addressCtrl);

    // 2. OData Routen unter /api/v4 anmelden
    // odataRouter.registerRoutes(router, "/api/v4");

    // 3. Statische Dateien ganz zum Schluss
    // router.get("*", serveStaticFiles("public/"));

	writeln("--- Registrierte Routen ---");
	foreach (route; router.getAllRoutes) {
		writefln("%-7s %s", route.method, route.pattern);
	}
	writeln("--------------------------");

    auto settings = new HTTPServerSettings;
    ushort port = environment.get("PORT", "8080").to!ushort;
    settings.port = port;
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);
    runApplication();
}