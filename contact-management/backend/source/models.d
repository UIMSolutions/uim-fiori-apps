module models;

import std.datetime;
import std.uuid : randomUUID;
@safe:
struct Address {
    string street;
    string zipCode;
    string city;
    string country;
}
struct Contact {
    string id;
    string firstName;
    string lastName;
    string email;
    string phone;
    string company;
    Address address;
}
/// Repository zur In-Memory-Datenhaltung für die lokale Entwicklung
class ContactRepository {
    private Contact[string] contacts;
    this() {
        // Initiale Testdaten beim Start laden
        contacts["1"] = Contact("1", "Max", "Mustermann", "max@example.com", "+49 89 123456", "Mustermann GmbH", Address("Hauptstraße 1", "80331", "München", "Deutschland"));
        contacts["2"] = Contact("2", "Erika", "Musterfrau", "erika@example.com", "+49 89 654321", "Tech AG", Address("Bahnhofstraße 12", "80333", "München", "Deutschland"));
    }
    Contact[] getAll() {
        return contacts.values;
    }
    Contact getById(string id) {
        if (auto c = id in contacts) return *c;
        return Contact.init;
    }
    Contact save(Contact contact) {
        if (contact.id.length == 0) {
            contact.id = randomUUID().toString();
        }
        contacts[contact.id] = contact;
        return contact;
    }
    bool remove(string id) {
        return contacts.remove(id);
    }
}