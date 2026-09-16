module main;
import vibe.d; // <-- Dieser Import fehlte
import uim.fiori;
@safe:
struct Person {
    int id;
    string name;
    string email;
    string role;
}
// REST-Schnittstelle definieren
@path("/api/persons")
interface PersonAPI {
    // GET /api/persons
    Person[] getPersons();
    // POST /api/persons
    Person postPersons(Person person);
    // DELETE /api/persons/:id
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
        return persons;
    }
    override Person postPersons(Person person) {
        person.id = nextId++;
        persons ~= person;
        return person;
    }
    override void deletePersons(int _id) {
        import std.algorithm : remove, countUntil;
        auto idx = persons.countUntil!(p => p.id == _id);
        if (idx >= 0) {
            persons = persons.remove(idx);
        }
    }
}
void getIndex(HTTPServerRequest req, HTTPServerResponse res)
{
    // Rendert views/index.dt
    res.render!("index.dt");
}
void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;
    // CORS Middleware
    router.any("*", &enableCORS);
    // REST-Interface registrieren
    router.registerRestInterface(new PersonWebAPI());
    // Static Files (Frontend)
    router.get("/", &getIndex);
    router.get("*", serveStaticFiles("public/"));
    listenHTTP(settings, router);
    runApplication();
}