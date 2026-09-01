module controller;

import uim.fiori;
import domain;
@safe:

class AddressController : ODataController {
    protected Json[string] store;

    // Collect related contacts for one address from the in-memory store.
    protected Json getContactsForAddress(string addressId) @trusted {
        writeln("AdressController:Fetching contacts for addressId: ", addressId);
        
        Json contacts = Json.emptyArray;

        if (auto items = "Contacts" in store) {
            foreach (item; (*items).byValue) {
                bool matches = false;
                if ("AddressId" in item) {
                    matches = item["AddressId"].get!string == addressId;
                } else if ("AddressId" in item) {
                    matches = item["AddressId"].get!string == addressId;
                }

                if (matches) {
                    contacts.appendArrayElement(item);
                }
            }
        }

        return contacts;
    }

    this() {
        // Initialer In-Memory Speicher
        store["Addresses"] = Json.emptyArray;
                // Initial-Daten

        auto addr1 = domain.Address();
        addr1.Id = "1001";
        addr1.FirstName = "Max";
        addr1.LastName = "Mustermann";
        addr1.Street = "Leopoldstraße 12";
        addr1.City = "München";
        addr1.PostalCode = "80802";
        addr1.Country = "Deutschland";

        auto addr2 = domain.Address();
        addr2.Id = "1002";
        addr2.FirstName = "Erika";
        addr2.LastName = "Musterfrau";
        addr2.Street = "Hauptstraße 45";
        addr2.City = "Nürnberg";
        addr2.PostalCode = "90402";
        addr2.Country = "Deutschland";

        store["Addresses"] ~= addr1.toJson();
        store["Addresses"] ~= addr2.toJson();
    }

    override Json getEntitySet(string entitySetName, string expand = "") {
        writeln("AdressController:Fetching entity set: ", entitySetName, " with expand: ", expand);

        Json res = Json.emptyObject;
        res["@odata.context"] = "/api/v4/$metadata#" ~ entitySetName;
        
        writeln("Store contents for ", entitySetName, ": ", store[entitySetName]);
        Json list = store.get(entitySetName, Json.emptyArray);

        // Falls $expand=Contacts angefordert wurde, Relationen dazuhängen
        if (expand == "Contacts") {
            foreach (ref item; list.byValue) {
                string addressId = item["Id"].get!string;
                item["Contacts"] = getContactsForAddress(addressId);
            }
        }

        res["value"] = list;
        return res;
    }
    unittest {
        // auto controller = new AddressController();
        // auto res = controller.getEntitySet("Addresses");
        // assert(res["@odata.context"] == "$metadata#Addresses");
        // assert(res["value"].isArray);
    }

    override Json getEntity(string entitySetName, string id, string expand = "") {
        writeln("AdressController:Fetching entity: ", entitySetName, " with id: ", id, " and expand: ", expand);
        if (auto items = entitySetName in store) {
            foreach (item; (*items).byValue) {
                if ("Id" in item && item["Id"].get!string == id) {
                    Json entity = item;
                    entity["@odata.context"] = "$metadata#" ~ entitySetName ~ "/$entity";
                    return entity;
                }
            }
        }
        return Json.undefined;
    }
    unittest {
        auto controller = new AddressController();
        auto addr = domain.Address();
        addr.Id = "1001";
        addr.FirstName = "Max";
        addr.LastName = "Mustermann";
        addr.Street = "Leopoldstraße 12";
        addr.City = "München";
        addr.PostalCode = "80802";
        addr.Country = "Deutschland";
        controller.createEntity("Addresses", serializeToJson(addr));
        auto res = controller.getEntity("Addresses", "1001");
        assert(res["@odata.context"] == "$metadata#Addresses/$entity");
        assert(res["FirstName"].get!string == "Max");
    }

    override Json createEntity(string entitySetName, Json payload) {
        writeln("AdressController:Creating entity in ", entitySetName, ": ", payload);

        Json newEntity = payload;

        // 1. Sichere Id-Vergabe
        if ("Id" !in newEntity || newEntity["Id"].get!string.length == 0) {
            newEntity["Id"] = Clock.currTime.toUnixTime().to!string;
        }

        // 2. OData v4 Einzel-Kontext setzen
        newEntity["@odata.context"] = "$metadata#" ~ entitySetName ~ "/$entity";

        // 3. Im Speicher ablegen
        if (entitySetName !in store) {
            store[entitySetName] = Json.emptyArray;
        }
        store[entitySetName].appendArrayElement(newEntity);

        return newEntity;
    }
    unittest {
        auto controller = new AddressController();
        Json payload = Json.emptyObject;
        payload["FirstName"] = "John";
        payload["LastName"] = "Doe";
        auto res = controller.createEntity("Addresses", payload);
        assert(res["@odata.context"] == "$metadata#Addresses/$entity");
        assert(res["FirstName"].get!string == "John");
    }

    override Json updateEntity(string entitySetName, string id, Json payload) @trusted {
        writeln("AdressController:AdressController:Updating entity in ", entitySetName, " with id: ", id, ": ", payload);

        if (auto items = entitySetName in store) {
            foreach (ref item; (*items).byValue) {
                if ("Id" in item && item["Id"].get!string == id) {
                    // Felder aktualisieren
                    foreach (string key, value; payload) {
                        if (key != "@odata.context" && key != "Id") {
                            item[key] = value;
                        }
                    }
                    item["@odata.context"] = "$metadata#" ~ entitySetName ~ "/$entity";
                    return item;
                }
            }
        }
        return Json.undefined;
    }
    unittest {
        auto controller = new AddressController();
        Json payload = Json.emptyObject;
        payload["FirstName"] = "Jane";
        payload["LastName"] = "Smith";
        auto created = controller.createEntity("Addresses", payload);
        string id = created["Id"].get!string;

        Json updatePayload = Json.emptyObject;
        updatePayload["FirstName"] = "Janet";
        auto updated = controller.updateEntity("Addresses", id, updatePayload);
        assert(updated["@odata.context"] == "$metadata#Addresses/$entity");
        assert(updated["FirstName"].get!string == "Janet");
    }

    override bool deleteEntity(string entitySetName, string id) {
        writeln("AdressController:Deleting entity in ", entitySetName, " with id: ", id);
        if (auto items = entitySetName in store) {
            Json newArray = Json.emptyArray;
            bool found = false;

            foreach (item; (*items).byValue) {
                if ("Id" in item && item["Id"].get!string == id) {
                    found = true;
                } else {
                    newArray.appendArrayElement(item);
                }
            }

            if (found) {
                store[entitySetName] = newArray;
                return true;
            }
        }
        return false;
    }
    unittest {
        auto controller = new AddressController();
        Json payload = Json.emptyObject;
        payload["FirstName"] = "Alice";
        payload["LastName"] = "Johnson";
        auto created = controller.createEntity("Addresses", payload);
        string id = created["Id"].get!string;

        bool deleted = controller.deleteEntity("Addresses", id);
        assert(deleted);

        auto res = controller.getEntity("Addresses", id);
        assert(res.isUndefined);
    }

    Json getEntitiesJson() {
        /// Hilfsmethode zur Bereitstellung der Adress-Daten
        Json response = Json.emptyObject;
        response["@odata.context"] = "/api/v4/$metadata#Addresses";
        response["value"] = store.get("Addresses", Json.emptyArray);

        return response;
    }

}
unittest {
    auto controller = new AddressController();
    Json payload = Json.emptyObject;
    payload["FirstName"] = "Bob";
    payload["LastName"] = "Brown";
    auto created = controller.createEntity("Addresses", payload);
    string id = created["Id"].get!string;

    bool deleted = controller.deleteEntity("Addresses", id);
    assert(deleted);

    auto res = controller.getEntity("Addresses", id);
    assert(res.isUndefined);
}