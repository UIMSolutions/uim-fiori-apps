module uim_fiori_apps;

import std.exception : enforce;

version(HaveVibeD)
{
	import vibe.data.json : JSONValue, serializeToJsonString;

	private string toJsonString(JSONValue value)
	{
		return serializeToJsonString(value);
	}
}
else
{
	import std.json : JSONValue;

	private string toJsonString(JSONValue value)
	{
		return value.toString();
	}
}

struct FioriAppConfig
{
	string id;
	string title;
	string description;
	string applicationVersion = "1.0.0";
	string i18nPath = "i18n/i18n.properties";
}

JSONValue buildManifest(FioriAppConfig config)
{
	enforce(config.id.length > 0, "Fiori application id must not be empty.");
	enforce(config.title.length > 0, "Fiori application title must not be empty.");
	enforce(config.applicationVersion.length > 0, "Fiori application version must not be empty.");
	enforce(config.i18nPath.length > 0, "Fiori i18n path must not be empty.");

	return JSONValue([
		"_version": JSONValue("1.59.0"),
		"sap.app": JSONValue([
			"id": JSONValue(config.id),
			"type": JSONValue("application"),
			"title": JSONValue(config.title),
			"description": JSONValue(config.description),
			"applicationVersion": JSONValue([
				"version": JSONValue(config.applicationVersion)
			]),
			"i18n": JSONValue(config.i18nPath)
		])
	]);
}

string buildManifestJson(FioriAppConfig config)
{
	return toJsonString(buildManifest(config));
}

unittest
{
	auto manifest = buildManifest(FioriAppConfig(
		id: "com.uim.demo",
		title: "UIM Demo",
		description: "Demo SAP Fiori app"
	));

	assert(manifest["sap.app"]["id"].str == "com.uim.demo");
	assert(manifest["sap.app"]["title"].str == "UIM Demo");
	assert(manifest["sap.app"]["applicationVersion"]["version"].str == "1.0.0");
	assert(manifest["sap.app"]["i18n"].str == "i18n/i18n.properties");

	auto manifestText = buildManifestJson(FioriAppConfig(
		id: "com.uim.demo",
		title: "UIM Demo",
		description: "Demo SAP Fiori app"
	));
	assert(manifestText.length > 0);
}

unittest
{
	import std.exception : assertThrown;

	assertThrown!Exception(buildManifest(FioriAppConfig(
		id: "",
		title: "UIM Demo",
		description: "Demo SAP Fiori app"
	)));
}
