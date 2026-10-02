module app;

import std.algorithm : canFind, startsWith;
import std.conv : to;
import std.path : buildPath;
import std.process : environment;
import vibe.d;

import data;
import odata4;

enum servicePath = "/odata/v4/shop";

void main()
{
	auto webapp = environment.get("WEBAPP_DIR", buildPath("..", "webapp"));
	auto port = environment.get("PORT", "8080").to!ushort;

	auto router = new URLRouter;
	router.get(servicePath ~ "/", (HTTPServerRequest req, HTTPServerResponse res) {
		res.headers["OData-Version"] = "4.0";
		auto sets = Json.emptyArray;
		foreach (name; entitySetNames)
		{
			auto s = Json.emptyObject;
			s["name"] = name;
			s["kind"] = "EntitySet";
			s["url"] = name;
			sets ~= s;
		}
		auto o = Json.emptyObject;
		o["@odata.context"] = "$metadata";
		o["value"] = sets;
		res.writeJsonBody(o);
	});
	router.get(servicePath ~ "/$metadata", (HTTPServerRequest req, HTTPServerResponse res) {
		res.headers["OData-Version"] = "4.0";
		res.writeBody(metadataXml, "application/xml");
	});
	router.any(servicePath ~ "/*", (HTTPServerRequest req, HTTPServerResponse res) {
		res.headers["OData-Version"] = "4.0";
		try
		{
			auto path = req.path[servicePath.length + 1 .. $];
			switch (req.method)
			{
			case HTTPMethod.GET:
				string[string] query;
				foreach (k, v; req.query.byKeyValue)
					query[k] = v;
				res.writeJsonBody(handleRequest(path, query));
				break;
			case HTTPMethod.POST:
				res.writeJsonBody(createEntity(path, req.json), 201);
				break;
			case HTTPMethod.PATCH:
			case HTTPMethod.PUT:
				res.writeJsonBody(updateEntity(path, req.json));
				break;
			case HTTPMethod.DELETE:
				deleteEntity(path);
				res.statusCode = 204;
				res.writeVoidBody();
				break;
			default:
				throw new ODataException(405, "Method not allowed");
			}
		}
		catch (ODataException e)
		{
			res.statusCode = e.status;
			auto err = Json.emptyObject;
			err["code"] = e.status.to!string;
			err["message"] = e.msg;
			auto o = Json.emptyObject;
			o["error"] = err;
			res.writeJsonBody(o);
		}
	});
	router.get("*", (HTTPServerRequest req, HTTPServerResponse res) {
		auto rel = req.path == "/" ? "index.html" : req.path[1 .. $];
		auto file = buildPath(webapp, rel);
		import std.file : exists, isFile;
		if (rel.canFind("..") || !exists(file) || !isFile(file))
		{
			res.statusCode = 404;
			res.writeBody("Not found");
			return;
		}
		sendFile(req, res, NativePath(file));
	});

	auto settings = new HTTPServerSettings;
	settings.port = port;
	settings.bindAddresses = ["0.0.0.0"];
	listenHTTP(settings, router);
	logInfo("Open http://localhost:%s/", port);
	runApplication();
}
