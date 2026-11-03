import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"]; // Wichtig für Container-Networking

    auto router = new URLRouter;
    router.get("/api/text", &textHandler);
    router.get("/", &readBackend);
    
    listenHTTP(settings, router);
    runApplication();
}

void readBackend(HTTPServerRequest req, HTTPServerResponse serverRes) {
    // Korrekte interne C2C-Adresse ohne öffentliche SAP-Domain
    requestHTTP("https://service01.cfapps.eu30.hana.ondemand.com/api/text",
        (scope HTTPClientRequest clientReq) {
            // Optional: Request-Header oder Parameter setzen
        },
        (scope HTTPClientResponse clientRes) {
            if (clientRes.statusCode == 200) {
                // Zugriff auf den äußeren Server-Response über den umbenannten Parameter
                serverRes.writeBody("Hello from service01!");
            } else {
                serverRes.writeBody("Error from service01!");
            }
        }
    );
}

void textHandler(HTTPServerRequest req, HTTPServerResponse res) {
    res.writeBody("Hello from service02!");
}
