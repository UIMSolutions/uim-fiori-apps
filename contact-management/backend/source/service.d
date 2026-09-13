module service;
import vibe.d;
import models;
@safe:
/// REST-Interface für Kontakte
/// vibe.d erzeugt daraus automatisch die JSON-Endpunkte unter /api/v1/Contacts
@path("/api/v1")
interface IContactService {
    @path("/Contacts")
    Contact[] getContacts();
    @path("/Contacts/:id")
    Contact getContact(string _id);
    @path("/Contacts")
    @method(HTTPMethod.POST)
    Contact createContact(Contact contact);
    @path("/Contacts/:id")
    @method(HTTPMethod.PUT)
    Contact updateContact(string _id, Contact contact);
    @path("/Contacts/:id")
    @method(HTTPMethod.DELETE)
    void deleteContact(string _id);
}
/// Konkrete Implementierung der REST-Schnittstelle
class ContactService : IContactService {
    private ContactRepository repo;
    this(ContactRepository repo) {
        this.repo = repo;
    }
    override Contact[] getContacts() {
        return repo.getAll();
    }
    override Contact getContact(string _id) {
        return repo.getById(_id);
    }
    override Contact createContact(Contact contact) {
        return repo.save(contact);
    }
    override Contact updateContact(string _id, Contact contact) {
        contact.id = _id;
        return repo.save(contact);
    }
    override void deleteContact(string _id) {
        repo.remove(_id);
    }
}