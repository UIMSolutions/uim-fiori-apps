module app;

import vibe.d;
import std.process : environment;
import std.conv : to;
import bulletinboard.infrastructure.repositories.in_memory_repository;
import bulletinboard.application.usecases.query_service;
import bulletinboard.presentation.http.odata_controller;

@safe:

void enableCORS(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, X-Requested-With";

    if (req.method == HTTPMethod.OPTIONS) {
        res.writeBody("", 200);
        return;
    }
}

void main() {
    auto repository = new InMemoryBulletinBoardRepository();
    auto queryService = new BulletinBoardQueryService(repository);
    auto controller = new ODataV2Controller(queryService);

    auto router = new URLRouter;

    router.any("*", &enableCORS);

    router.get("/health", &controller.getHealth);

    router.get("/odata/v2/BULLETINBOARD_SRV", &controller.getServiceDocument);
    router.get("/odata/v2/BULLETINBOARD_SRV/", &controller.getServiceDocument);
    router.get("/odata/v2/BULLETINBOARD_SRV/$metadata", &controller.getMetadata);

    router.get("/odata/v2/BULLETINBOARD_SRV/Posts", &controller.getPosts);
    router.get("/odata/v2/BULLETINBOARD_SRV/Posts*", &controller.getPostOrNavigation);
    router.get("/odata/v2/BULLETINBOARD_SRV/Categories", &controller.getCategories);
    router.get("/odata/v2/BULLETINBOARD_SRV/Comments", &controller.getComments);

    // Serve the existing UI5 app for local end-to-end testing with this backend.
    router.get("/", serveStaticFiles("../frontend/webapp/index.html"));
    router.get("*", serveStaticFiles("../frontend/webapp/"));

    auto settings = new HTTPServerSettings;
    settings.port = to!ushort(environment.get("PORT", "8080"));
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);

    logInfo("Bulletin Board backend listening on port %s", settings.port);
    runApplication();
}
