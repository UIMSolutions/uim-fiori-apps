module config;
import std.json, std.process, std.exception, std.conv : to;

string postgresConnInfo() {
  auto root = parseJSON(environment.get("VCAP_SERVICES", "{}"));
  enforce("postgresql-db" in root.object, "PostgreSQL-Service ist nicht gebunden");
  auto c = root["postgresql-db"].array[0]["credentials"];
  return "host=" ~ c["hostname"].str ~ " port=" ~ c["port"].integer.to!string ~
    " dbname=" ~ c["dbname"].str ~ " user=" ~ c["username"].str ~
    " password=" ~ c["password"].str ~ " sslmode=require";
}

