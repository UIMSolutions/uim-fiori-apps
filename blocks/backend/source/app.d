import vibe.d;

@safe:

struct BuildingBlock {
    string id;
    string name;
    string type; // Architecture, Solution, Interface
    string description;
    string status;
}

// 1. Interface-Kontrakt definieren
interface IEnterpriseArchitectureService {
    @path("/api/buildingblocks")
    BuildingBlock[] getBlocks(string type = null);

    @path("/api/buildingblocks/:id")
    BuildingBlock getBlock(string _id);
}

class EnterpriseArchitectureService : IEnterpriseArchitectureService{
    private BuildingBlock[string] _data;

    this() {
        // Beispiel-Daten
        _data["AB-01"] = BuildingBlock("AB-01", "Domain Model Core", "Architecture", "Zentrales Domänenmodell", "Active");
        _data["LB-01"] = BuildingBlock("LB-01", "SAP S/4HANA Finance", "Solution", "Haupt-ERP Finanzmodul", "Active");
        _data["IF-01"] = BuildingBlock("IF-01", "REST API v1", "Interface", "Schnittstelle zwischen vibe.d und Fiori", "In Progress");
    }

    BuildingBlock[] getBlocks(string type = null) {
        BuildingBlock[] result;
        foreach (block; _data.byValue) {
            if (type.length == 0 || block.type == type) {
                result ~= block;
            }
        }
        return result;
    }

    BuildingBlock getBlock(string _id) {
        if (auto b = _id in _data) return *b;
        throw new HTTPStatusException(HTTPStatus.notFound, "Entity nicht gefunden");
    }
}

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;
    
    // CORS Header für UI5 Dev-Server aktivieren
    router.any("*", (req, res) {
        res.headers["Access-Control-Allow-Origin"] = "*";
        res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS";
        res.headers["Access-Control-Allow-Headers"] = "Content-Type";
        if (req.method == HTTPMethod.OPTIONS) {
            res.writeBody("");
            return;
        }
    });

    router.registerRestInterface(new EnterpriseArchitectureService);
    
    // Statische SAPUI5-Dateien aus /public ausliefern (falls nicht via UI5 Tooling betrieben)
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    runApplication();
}