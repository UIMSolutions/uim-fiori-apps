/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.cli;

/// Command line interface & administrative commands.
///
/// The CLI is the entry point of the executable: `serve` (default) starts the HTTP/OData server,
/// `gui` the GtkD desktop client; all other commands work directly on the configured storage.
import std.algorithm : canFind, map, max, min;
import std.array : appender, array, join, replicate;
import std.conv : to;
import std.file : exists, readText, write;
import std.format : format;
import std.getopt : GetoptResult, getopt, GetOptException, getoptConfig = config;
import std.range : repeat;
import std.stdio : stderr, stdout;
import std.string : strip;
import std.utf : count;

import vibe.data.json : Json, parseJsonString, JSONException;

import uim.fiori_blocks.application;
import uim.fiori_blocks.composition;
import uim.fiori_blocks.domain.exceptions;
import uim.fiori_blocks.infrastructure.configuration;
import uim.fiori_blocks.presentation.http.server : runServer;
import uim.fiori_blocks.presentation.odata.edm : generateMetadata;
import uim.fiori_blocks.presentation.odata.errors : ODataException;
import uim.fiori_blocks.presentation.odata.parser : parseFilter, parseOrderBy, parseSelect;

@safe:

enum appVersion = "2.0.0";

enum usage = `blocks-odatav4 ` ~ appVersion ~ ` - EA building blocks manager (OData v4 / CLI / GtkD)

Usage: blocks-odatav4 [options] [command] [arguments]

Commands:
  serve                          Start the HTTP + OData v4 server (default)
  gui                            Start the GtkD desktop client (desktop build)
  sets                           List entity sets with their counts
  list   <Set>                   List entities (--filter --orderby --top --skip --select --search)
  get    <Set> <ID>              Show one entity as JSON
  create <Set>                   Create an entity from --data '<json>' or --file <file>
  update <Set> <ID>              Partially update an entity (PATCH) from --data / --file
  delete <Set> <ID>              Delete an entity
  export [<Set>]                 Export one set (JSON array) or all sets (JSON object) [--out <file>]
  import [<Set>] --file <file>   Replace one set / all sets from an export file (validated, atomic)
  metadata                       Print the OData $metadata document [--out <file>]
  config                         Show the effective configuration
  help | version

Options:
  -c, --config <file>      Configuration file (default: config/default.json if present)
  -p, --port <n>           HTTP port
      --bind <addrs>       Comma separated bind addresses
      --storage <kind>     memory | file
      --data-dir <dir>     Directory of the JSON file storage
      --public-dir <dir>   Directory of the Fiori frontend
      --log-level <level>  debug | info | warn | error
  -f, --format <fmt>       table | json (list, sets)
      --filter <expr>      OData $filter expression, e.g. "contains(Name,'Core') and Version eq '1.0'"
      --orderby <spec>     e.g. "Name desc,ID"
      --top <n> / --skip <n>
      --select <props>     e.g. "ID,Name"
      --search <text>      Free text search
  -d, --data <json>        JSON payload for create / update
      --file <file>        JSON file for create / update / import
  -o, --out <file>         Output file for export / metadata
`;

/// Parsed command line.
struct CliOptions {
  string configFile;
  string[string] overrides; /// configuration overrides (option name -> value)
  string format = "table";
  string filter, orderby, select, search, data, file, output;
  long top = -1, skip = 0;
  bool help, version_;
  string command = "serve";
  string[] arguments;
}

CliOptions parseArguments(string[] args) @trusted {
  CliOptions o;
  string port, bind, storage, dataDir, publicDir, logLevel;
  auto parsed = getopt(args,
    getoptConfig.caseSensitive,
    "config|c", &o.configFile,
    "port|p", &port,
    "bind", &bind,
    "storage", &storage,
    "data-dir", &dataDir,
    "public-dir", &publicDir,
    "log-level", &logLevel,
    "format|f", &o.format,
    "filter", &o.filter,
    "orderby", &o.orderby,
    "top", &o.top,
    "skip", &o.skip,
    "select", &o.select,
    "search", &o.search,
    "data|d", &o.data,
    "file", &o.file,
    "out|o", &o.output,
    "version|v", &o.version_,
    "help|h", &o.help);

  foreach (pair; [["port", port], ["bindAddresses", bind], ["storage", storage], ["dataDir", dataDir],
      ["publicDir", publicDir], ["logLevel", logLevel]])
    if (pair[1].length)
      o.overrides[pair[0]] = pair[1];

  if (args.length > 1) {
    o.command = args[1];
    o.arguments = args[2 .. $];
  }
  if (o.help)
    o.command = "help";
  if (o.version_)
    o.command = "version";
  return o;
}

/// Entry point of the executable.
int runCli(string[] args) @trusted {
  CliOptions options;
  try
    options = parseArguments(args);
  catch (GetOptException e) {
    stderr.writeln("Error: ", e.msg, "\n\n", usage);
    return 2;
  }

  auto output = appender!string;
  int exitCode;
  try {
    exitCode = execute(options, output, &runServer, &startGui);
  } catch (CliException e) {
    stderr.writeln("Error: ", e.msg);
    exitCode = e.exitCode;
  } catch (ODataException e) {
    stderr.writeln("Error: ", e.msg);
    exitCode = 2;
  } catch (DomainException e) {
    stderr.writeln("Error: ", e.msg);
    exitCode = 1;
  } catch (JSONException e) {
    stderr.writeln("Error: invalid JSON: ", e.msg);
    exitCode = 2;
  } catch (Exception e) {
    stderr.writeln("Error: ", e.msg);
    exitCode = 1;
  }
  stdout.write(output.data);
  return exitCode;
}

class CliException : Exception {
  int exitCode;

  this(string msg, int exitCode = 2, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    this.exitCode = exitCode;
    super(msg, file, line);
  }
}

alias Runner = int function(AppContext) @safe;

/// Executes a command; output is appended to `output` (testable without stdout).
int execute(W)(CliOptions options, ref W output, Runner server, Runner gui) {
  switch (options.command) {
  case "help":
    output ~= usage;
    return 0;
  case "version":
    output ~= appVersion ~ "\n";
    return 0;
  default:
    break;
  }

  auto config = loadConfig(options.configFile);
  foreach (name, value; options.overrides)
    setOption(config, name, value);
  if (options.overrides.length)
    config.sources ~= "command line";

  switch (options.command) {
  case "serve":
    return server(bootstrap(config));
  case "gui":
    return gui(bootstrap(config));
  case "config":
    output ~= configJson(config).toPrettyString ~ "\n";
    return 0;
  default:
    break;
  }

  auto context = bootstrap(config);
  auto catalog = context.catalog;
  auto args = options.arguments;

  switch (options.command) {
  case "sets":
    if (options.format == "json") {
      auto result = Json.emptyObject;
      foreach (s; catalog.all)
        result[s.name] = s.count;
      output ~= result.toPrettyString ~ "\n";
    } else {
      string[][] rows;
      foreach (s; catalog.all)
        rows ~= [s.name, s.typeName, s.count.to!string];
      output ~= renderTable(["EntitySet", "EntityType", "Count"], rows);
    }
    return 0;

  case "list":
    auto set = catalog[argument(args, 0, "entity set")];
    QuerySpec spec;
    if (options.filter.length)
      spec.filter = parseFilter(options.filter);
    if (options.orderby.length)
      spec.orderBy = parseOrderBy(options.orderby);
    if (options.select.length)
      spec.select = parseSelect(options.select);
    spec.top = options.top;
    spec.skip = options.skip;
    spec.search = options.search;
    auto result = set.query(spec);
    if (options.format == "json")
      output ~= Json(result.items).toPrettyString ~ "\n";
    else
      output ~= renderEntities(set, result.items, spec.select) ~ format("(%s of %s)\n", result.items.length, result.total);
    return 0;

  case "get":
    auto set = catalog[argument(args, 0, "entity set")];
    output ~= set.get(argument(args, 1, "ID")).toPrettyString ~ "\n";
    return 0;

  case "create":
    auto set = catalog[argument(args, 0, "entity set")];
    auto created = set.create(payload(options));
    warnIfVolatile(context);
    output ~= created.toPrettyString ~ "\n";
    return 0;

  case "update":
    auto set = catalog[argument(args, 0, "entity set")];
    auto updated = set.patch(argument(args, 1, "ID"), payload(options));
    warnIfVolatile(context);
    output ~= updated.toPrettyString ~ "\n";
    return 0;

  case "delete":
    auto set = catalog[argument(args, 0, "entity set")];
    auto id = argument(args, 1, "ID");
    set.remove(id);
    warnIfVolatile(context);
    output ~= "Deleted " ~ set.name ~ "('" ~ id ~ "')\n";
    return 0;

  case "export":
    Json data;
    if (args.length) {
      data = Json(catalog[args[0]].list);
    } else {
      data = Json.emptyObject;
      foreach (s; catalog.all)
        data[s.name] = Json(s.list);
    }
    writeOutput(options, output, data.toPrettyString ~ "\n", "Exported");
    return 0;

  case "import":
    if (options.file.length == 0)
      throw new CliException("import requires --file <file>");
    auto data = parseJsonString(readFile(options.file), options.file);
    size_t imported;
    catalog.transaction(() @safe {
      if (args.length) {
        if (data.type != Json.Type.array)
          throw new CliException("Expected a JSON array for entity set " ~ args[0]);
        catalog[args[0]].importAll(data.get!(Json[]));
        imported = data.length;
      } else {
        if (data.type != Json.Type.object)
          throw new CliException("Expected a JSON object {\"EntitySet\": [...]} to import all sets");
        foreach (string name, items; data.byKeyValue) {
          if (items.type != Json.Type.array)
            throw new CliException("Expected a JSON array for entity set " ~ name);
          catalog[name].importAll(items.get!(Json[]));
          imported += items.length;
        }
      }
    });
    warnIfVolatile(context);
    output ~= format("Imported %s entities\n", imported);
    return 0;

  case "metadata":
    writeOutput(options, output, generateMetadata(catalog, config.odataNamespace, config.odataContainer), "Metadata written");
    return 0;

  default:
    throw new CliException("Unknown command '" ~ options.command ~ "' (see --help)");
  }
}

private string argument(string[] args, size_t index, string what) {
  if (index >= args.length)
    throw new CliException("Missing argument: " ~ what);
  return args[index];
}

private Json payload(CliOptions options) {
  if (options.data.length)
    return parseJsonString(options.data, "--data");
  if (options.file.length)
    return parseJsonString(readFile(options.file), options.file);
  throw new CliException("Missing payload: use --data '<json>' or --file <file>");
}

private string readFile(string file) @trusted {
  if (!file.exists)
    throw new CliException("File not found: " ~ file);
  return readText(file);
}

private void writeOutput(W)(CliOptions options, ref W output, string content, string message) @trusted {
  if (options.output.length) {
    write(options.output, content);
    output ~= message ~ " to " ~ options.output ~ "\n";
  } else
    output ~= content;
}

private void warnIfVolatile(AppContext context) @trusted {
  if (context.config.storage == StorageKind.memory)
    stderr.writeln("Warning: storage is 'memory' - the change is lost when the command ends (use --storage file).");
}

Json configJson(const ref AppConfig config) {
  return Json([
    "port": Json(config.port),
    "bindAddresses": Json(config.bindAddresses.map!(a => Json(a)).array),
    "publicDir": Json(config.publicDir),
    "odataPath": Json(config.odataPath),
    "odataNamespace": Json(config.odataNamespace),
    "storage": Json(cast(string) config.storage),
    "dataDir": Json(config.dataDir),
    "logLevel": Json(config.logLevel),
    "cors": Json(config.cors),
    "sources": Json(config.sources.map!(s => Json(s)).array)
  ]);
}

/// Renders entities as table: scalar properties as text, collections as item count.
string renderEntities(IEntitySetService set, Json[] items, string[] select) {
  string[] columns;
  foreach (p; set.properties)
    if (select.length == 0 || p.key || select.canFind(p.name))
      columns ~= p.name;

  string[][] rows;
  foreach (item; items) {
    string[] row;
    foreach (column; columns) {
      auto value = column in item;
      if (value is null)
        row ~= "";
      else if (value.type == Json.Type.array)
        row ~= format("[%s]", value.length);
      else
        row ~= asString(*value);
    }
    rows ~= row;
  }
  return renderTable(columns, rows);
}

string renderTable(string[] headers, string[][] rows, size_t maxWidth = 32) {
  auto widths = headers.map!(h => h.count).array;
  foreach (row; rows)
    foreach (i, cell; row)
      widths[i] = max(widths[i], min(cell.count, maxWidth));

  string cut(string text, size_t width) {
    import std.utf : toUTF32, toUTF8;

    auto chars = text.toUTF32;
    if (chars.length > width)
      return (chars[0 .. width - 1] ~ "…"d).toUTF8;
    return text ~ ' '.repeat(width - chars.length).array.idup;
  }

  auto out_ = appender!string;
  foreach (i, h; headers)
    out_ ~= (i ? "  " : "") ~ cut(h, widths[i]);
  out_ ~= "\n";
  foreach (i, w; widths)
    out_ ~= (i ? "  " : "") ~ "-".replicate(w);
  out_ ~= "\n";
  foreach (row; rows) {
    foreach (i, cell; row)
      out_ ~= (i ? "  " : "") ~ cut(cell, widths[i]);
    out_ ~= "\n";
  }
  return out_.data;
}

private int startGui(AppContext context) {
  version (WithGui) {
    import uim.fiori_blocks.presentation.gui : runGui;

    return runGui(context);
  } else {
    throw new CliException("This build has no GUI. Build with: dub build --config=desktop", 1);
  }
}

///
unittest {
  static int noRun(AppContext) @safe {
    assert(0);
  }

  string run(string[] args) {
    auto o = parseArguments(["blocks"] ~ args ~ ["--log-level", "error", "--storage", "memory"]);
    auto output = appender!string;
    assert(execute(o, output, &noRun, &noRun) == 0);
    return output.data;
  }

  assert(run(["help"]).canFind("Usage:"));
  assert(run(["sets"]).canFind("ArchitectureBlocks"));
  auto listed = run(["list", "Users", "--filter", "Active eq true", "--orderby", "Username desc"]);
  assert(listed.canFind("editor") && !listed.canFind("viewer") && listed.canFind("(2 of 2)"));
  assert(run(["get", "BaseBlocks", "BB-01"]).canFind(`"Dependency`) || run(["get", "BaseBlocks", "BB-01"]).canFind(`"DependsOn"`));
  assert(run(["metadata"]).canFind("<EntityContainer"));
  assert(parseJsonString(run(["export"]))["Users"].length == 3);

  bool failed;
  try
    run(["list", "Nope"]);
  catch (EntityNotFoundException)
    failed = true;
  assert(failed);
}
