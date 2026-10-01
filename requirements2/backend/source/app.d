import vibe.d;
import api.odata_v4;

void main()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    // Static Files for SAPUI5 App
    router.get("*", serveStaticFiles("public/"));

    // OData v4 Service Endpoints
    auto odataAPI = new ODataV4Service();
    router.get("/odata/v4/reqmgmt/$metadata", &odataAPI.getMetadata);
    router.get("/odata/v4/reqmgmt/Projects", &odataAPI.getProjects);
    router.get("/odata/v4/reqmgmt/BusinessRequirements", &odataAPI.getBusinessRequirements);
    router.get("/odata/v4/reqmgmt/SolutionRequirements", &odataAPI.getSolutionRequirements);

    listenHTTP(settings, router);
    runApplication();
}