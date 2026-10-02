module app;

import std.algorithm : canFind, joiner, filter, map, sort, startsWith;
import std.array : array;
import std.conv : to;
import std.file : exists, readText;
import std.path : buildPath;
import std.process : environment;
import std.string : indexOf, strip, toLower;
import std.uni : isAlpha, isAlphaNum, isWhite;
import vibe.d;

import odata;

void main()
{
	auto webapp = environment.get("WEBAPP_DIR", buildPath("..", "webapp"));
	auto dataDir = buildPath(webapp, "localService", "mockdata");
	auto port = environment.get("PORT", "8080").to!ushort;
	enforce(exists(dataDir), "Mock data not found: " ~ dataDir);

	auto store = new DataStore(dataDir);
	auto router = new URLRouter;
	auto prefix = "/sap/opu/odata/IWBEP/EPM_DEVELOPER_SCENARIO_SRV";

	router.get(prefix ~ "/$metadata", (HTTPServerRequest req, HTTPServerResponse res) {
		res.headers["DataServiceVersion"] = "1.0";
		res.writeBody(readText(buildPath(webapp, "localService", "metadata.xml")),
			"application/xml");
	});
	router.get(prefix ~ "/", (HTTPServerRequest req, HTTPServerResponse res) {
		auto sets = entitySets.keys.sort.map!(k => `{"name":"` ~ k ~ `","url":"` ~ k ~ `"}`).array;
		res.writeBody(`{"d":{"EntitySets":[` ~ sets.joiner(",").to!string ~ `]}}`,
			"application/json");
	});
	router.get("*", (HTTPServerRequest req, HTTPServerResponse res) {
		if (req.requestURI.startsWith(prefix ~ "/"))
			handleODataGet(store, req, res, prefix);
		else if (req.path.startsWith("/sap/ui/demo/mock/images/"))
			serveFile(req, res, buildPath(dataDir, "images", req.path["/sap/ui/demo/mock/images/".length .. $]));
		else
			serveFile(req, res, buildPath(webapp, req.path == "/" ? "index.html" : req.path[1 .. $]));
	});

	auto settings = new HTTPServerSettings;
	settings.port = port;
	settings.bindAddresses = ["0.0.0.0"];
	listenHTTP(settings, router);
	logInfo("Shopping Cart backend: http://localhost:%s/", port);
	runApplication();
}

void handleODataGet(DataStore store, HTTPServerRequest req, HTTPServerResponse res, string prefix)
{
	import std.uri : decode;

	res.headers["DataServiceVersion"] = "2.0";
	try
	{
		auto path = req.requestURI;
		auto q = path.indexOf('?');
		if (q >= 0)
			path = path[0 .. q];
		auto segments = path[prefix.length .. $].split("/").filter!(s => s.length).map!(s => decode(s)).array;
		string[string] query;
		foreach (k, v; req.query.byKeyValue)
			query[k] = v;
		auto result = resolve(store, segments, query);
		res.writeBody(result.toString(), "application/json");
	}
	catch (ODataException e)
	{
		res.statusCode = e.status;
		res.writeBody(`{"error":{"code":"` ~ e.status.to!string ~ `","message":{"lang":"en","value":`
			~ Json(e.msg).toString() ~ `}}}`, "application/json");
	}
}

void serveFile(HTTPServerRequest req, HTTPServerResponse res, string file)
{
	import std.path : absolutePath, buildNormalizedPath;

	if (req.path.canFind("..") || !exists(file))
	{
		res.statusCode = 404;
		res.writeBody("Not found");
		return;
	}
	sendFile(req, res, NativePath(file));
}
