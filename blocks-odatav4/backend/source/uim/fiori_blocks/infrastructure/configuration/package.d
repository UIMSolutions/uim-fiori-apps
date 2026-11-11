/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.configuration;

/// Type-safe application configuration.
///
/// Precedence (lowest -> highest):
///   1. compiled-in defaults (`AppConfig.init`)
///   2. config file (`config/default.json`, or `--config <file>`)
///   3. environment variables (`PORT`, `BLOCKS_*`)
///   4. `VCAP_SERVICES` (credentials of a user-provided service named `blocks-config`)
///   5. command line options (applied by the CLI adapter)
import std.algorithm : canFind, map, splitter;
import std.array : array;
import std.conv : to;
import std.file : exists, readText;
import std.process : environment;
import std.string : strip, toLower;

import vibe.data.json : Json, parseJsonString;

@safe:

enum StorageKind : string {
  memory = "memory",
  file = "file"
}

struct AppConfig {
  string[] bindAddresses = ["127.0.0.1", "::1"];
  ushort port = 8080;
  string publicDir = "../frontend";
  string odataPath = "/odata/v4";
  string odataNamespace = "EAModel";
  string odataContainer = "EAService";
  StorageKind storage = StorageKind.memory;
  string dataDir = "data";
  string logLevel = "info";
  bool cors = true;
  string demoPassword = "Welcome1!";
  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];
}

/// Loads the configuration from file, environment and VCAP_SERVICES.
AppConfig loadConfig(string configFile = "") @trusted {
  AppConfig config;

  auto file = configFile.length ? configFile : findDefaultConfigFile();
  if (file.length) {
    if (!file.exists)
      throw new Exception("Config file not found: " ~ file);
    applyJson(config, parseJsonString(readText(file), file));
    config.sources ~= file;
  }

  applyEnvironment(config, environment.toAA);

  auto vcap = environment.get("VCAP_SERVICES");
  if (vcap.length) {
    applyVcapServices(config, parseJsonString(vcap, "VCAP_SERVICES"));
  }
  return config;
}

private string findDefaultConfigFile() {
  foreach (candidate; ["config/default.json", "backend/config/default.json"])
    if (candidate.exists)
      return candidate;
  return "";
}

/// Applies the members of a Json object to the config.
void applyJson(ref AppConfig config, Json json) {
  if (json.type != Json.Type.object)
    return;
  static foreach (name; ["port", "publicDir", "odataPath", "odataNamespace", "odataContainer",
      "storage", "dataDir", "logLevel", "cors", "demoPassword", "bindAddresses"]) {
    {
      auto value = name in json;
      if (value !is null)
        setOption(config, name, value.type == Json.Type.array
            ? value.get!(Json[]).map!(v => v.get!string).array.joinComma : value.to!string);
    }
  }
}

/// Applies environment variables (Cloud Foundry sets PORT).
void applyEnvironment(ref AppConfig config, string[string] env) {
  bool any;
  void take(string variable, string option) {
    if (auto value = variable in env) {
      setOption(config, option, *value);
      any = true;
    }
  }

  if (auto port = "PORT" in env) {
    // Cloud Foundry: listen on all interfaces
    setOption(config, "port", *port);
    config.bindAddresses = ["0.0.0.0"];
    any = true;
  }
  take("BLOCKS_BIND", "bindAddresses");
  take("BLOCKS_PUBLIC_DIR", "publicDir");
  take("BLOCKS_STORAGE", "storage");
  take("BLOCKS_DATA_DIR", "dataDir");
  take("BLOCKS_LOG_LEVEL", "logLevel");
  take("BLOCKS_CORS", "cors");
  take("BLOCKS_DEMO_PASSWORD", "demoPassword");
  if (any)
    config.sources ~= "environment";
}

/// Applies the credentials of the user-provided service "blocks-config" (highest priority).
void applyVcapServices(ref AppConfig config, Json vcap) {
  if (vcap.type != Json.Type.object)
    return;
  foreach (string label, instances; vcap.byKeyValue) {
    if (instances.type != Json.Type.array)
      continue;
    foreach (instance; instances.get!(Json[])) {
      if (instance["name"].opt!string == "blocks-config" && instance["credentials"].type == Json.Type.object) {
        applyJson(config, instance["credentials"]);
        config.sources ~= "VCAP_SERVICES";
      }
    }
  }
}

/// Sets a single option from its string representation (shared by all sources and the CLI).
void setOption(ref AppConfig config, string name, string value) {
  value = value.strip;
  switch (name) {
  case "port":
    config.port = value.to!ushort;
    break;
  case "bindAddresses":
    config.bindAddresses = value.splitter(',').map!(s => s.strip).array;
    break;
  case "publicDir":
    config.publicDir = value;
    break;
  case "odataPath":
    config.odataPath = value;
    break;
  case "odataNamespace":
    config.odataNamespace = value;
    break;
  case "odataContainer":
    config.odataContainer = value;
    break;
  case "storage":
    if (![cast(string) StorageKind.memory, cast(string) StorageKind.file].canFind(value.toLower))
      throw new Exception("Invalid storage '" ~ value ~ "' (expected memory or file)");
    config.storage = cast(StorageKind) value.toLower;
    break;
  case "dataDir":
    config.dataDir = value;
    break;
  case "logLevel":
    config.logLevel = value.toLower;
    break;
  case "cors":
    config.cors = ["1", "true", "yes", "on"].canFind(value.toLower);
    break;
  case "demoPassword":
    config.demoPassword = value;
    break;
  default:
    throw new Exception("Unknown configuration option: " ~ name);
  }
}

private string joinComma(string[] values) pure {
  import std.array : join;

  return values.join(",");
}

///
unittest {
  AppConfig config;
  applyJson(config, Json(["port": Json(9000), "storage": Json("file"), "bindAddresses": Json([Json("0.0.0.0")])]));
  assert(config.port == 9000 && config.storage == StorageKind.file && config.bindAddresses == ["0.0.0.0"]);

  applyEnvironment(config, ["PORT": "4711", "BLOCKS_CORS": "false"]);
  assert(config.port == 4711 && !config.cors && config.bindAddresses == ["0.0.0.0"]);

  auto vcap = Json([
    "user-provided": Json([
      Json(["name": Json("blocks-config"), "credentials": Json(["logLevel": Json("debug")])])
    ])
  ]);
  applyVcapServices(config, vcap);
  assert(config.logLevel == "debug");
}
