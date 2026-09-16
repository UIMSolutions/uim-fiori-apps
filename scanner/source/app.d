module app;

import std.conv : to;
import std.process : environment;

import vibe.core.log : logInfo;
import vibe.http.common : HTTPMethod;
import vibe.http.fileserver : serveStaticFile, serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings,
    listenHTTP;
import vibe.http.status : HTTPStatus;
import vibe.vibe : runApplication;

import scanner_middleware.application.services.gtt_dispatch_queue : GttDispatchQueue;
import scanner_middleware.application.usecases.capture_scan_usecase : CaptureScanUseCase;
import scanner_middleware.infrastructure.gtt.sap_gtt_http_gateway : SapGttHttpGateway;
import scanner_middleware.infrastructure.repositories.in_memory_scan_repository : InMemoryScanRepository;
import scanner_middleware.presentation.http.odata_controller : ODataController;
import scanner_middleware.presentation.http.scan_controller : ScanController;

void main() {
    auto repository = new InMemoryScanRepository();
    auto sapGttEndpoint = environment.get("SAP_GTT_ENDPOINT", "");
    auto sapGttToken = environment.get("SAP_GTT_TOKEN", "");
    auto sapGttMaxAttempts = to!size_t(environment.get("SAP_GTT_MAX_ATTEMPTS", "3"));
    auto sapGttGateway = new SapGttHttpGateway(sapGttEndpoint, sapGttToken);
    auto dispatchQueue = new GttDispatchQueue(sapGttGateway, sapGttMaxAttempts);
    auto captureScanUseCase = new CaptureScanUseCase(repository, dispatchQueue);
    auto controller = new ScanController(captureScanUseCase, repository, dispatchQueue);
    auto odataController = new ODataController(repository);

    auto router = new URLRouter();
    router.any("*", &enableCORS);
    controller.registerRoutes(router);
    odataController.registerRoutes(router);

    auto sapUi5SdkPath = environment.get("SAPUI5_SDK_PATH",
        "/home/oz/DEV/D/UIM2026/SAP/uim-fiori-apps/public/sapui5-sdk-1.151.0/");
    router.get("/resources/*", serveStaticFiles(sapUi5SdkPath));
    router.get("/", serveStaticFile("public/index.html"));
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings();
    settings.bindAddresses = ["0.0.0.0"];
    settings.port = to!ushort(environment.get("PORT", "8090"));

    listenHTTP(settings, router);
    logInfo("Scanner middleware listening on http://localhost:%s", settings.port);
    runApplication();
}

void enableCORS(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, X-Requested-With";
    if (req.method == HTTPMethod.OPTIONS) {
        res.writeBody("", cast(int) HTTPStatus.ok, "text/plain");
    }
}
