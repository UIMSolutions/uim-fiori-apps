import vibe.vibe;
import uim.fiori;
@safe:
struct Person {
	int id;
	string name;
	string email;
	string role;
}
// REST-Schnittstelle definieren
@path("/api")
interface PersonAPI {
	// GET /api/persons
	@path("/persons")
	Person[] getPersons();
	@path("/persons/:id")
	Person getPersons(int _id);
	// POST /api/persons
	@path("/persons")
	Person postPersons(Person person);
	// DELETE /api/persons/:id
	@path("/persons/:id")
	void deletePersons(int _id);
}
class PersonWebAPI : PersonAPI {
	private Person[] persons;
	private int nextId = 1;
	this() {
		persons = [
			Person(nextId++, "Erika Mustermann", "erika@example.com", "Developer"),
			Person(nextId++, "Max Mustermann", "max@example.com", "Manager")
		];
	}
	override Person[] getPersons() {
		writeln("Fetching all persons, count: ", persons.length);
		return persons;
	}
	override Person getPersons(int _id) {
		writeln("Fetching person with ID: ", _id);
		import std.algorithm : find, countUntil;
		auto idx = persons.countUntil!(p => p.id == _id);
		if (idx >= 0) {
			return persons[idx];
		}
		return Person.init;
	}
	override Person postPersons(@bodyParam(".person") Person person) {
		writeln("Creating new person: ", person.name);
		person.id = nextId++;
		persons ~= person;
		return person;
	}
	override void deletePersons(int _id) {
		writeln("Deleting person with ID: ", _id);
		import std.algorithm : remove, countUntil;
		auto idx = persons.countUntil!(p => p.id == _id);
		if (idx >= 0) {
			persons = persons.remove(idx);
		}
	}
}
void main() {
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	auto router = new URLRouter;
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
	// REST-Interface registrieren
	router.registerRestInterface(new PersonWebAPI());
	// Static Files (Frontend)
	router.get("*", serveStaticFiles("public/"));
	auto listener = listenHTTP(settings, router);
	scope (exit) {
		listener.stopListening();
	}
	writeln("--- Registrierte Routen ---");
	foreach (route; router.getAllRoutes) {
		writefln("%-7s %s", route.method, route.pattern);
	}
	writeln("--------------------------");
	listenHTTP(settings, router);
	runApplication();
}
void hello(HTTPServerRequest req, HTTPServerResponse res) {
	res.writeBody("Hello, World!");
}
