/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.url;

/// URL helpers shared by the HTTP routes and the $batch processor.
import std.algorithm : startsWith;
import std.string : indexOf;

import vibe.textfilter.urlencode : formDecode, urlDecode;

import uim.fiori_blocks.presentation.odata.errors;

@safe:

/// Decodes "a=1&b=x%20y" into an associative array ('+' is treated as space).
string[string] parseQueryString(string query) {
  string[string] result;
  size_t start;
  while (start <= query.length) {
    auto end = query.indexOf('&', start);
    auto pair = query[start .. end < 0 ? query.length : end];
    if (pair.length) {
      auto eq = pair.indexOf('=');
      try {
        if (eq < 0)
          result[formDecode(pair)] = "";
        else
          result[formDecode(pair[0 .. eq])] = formDecode(pair[eq + 1 .. $]);
      } catch (Exception e) {
        throw badRequest("Invalid URL encoding in query string: " ~ e.msg);
      }
    }
    if (end < 0)
      break;
    start = end + 1;
  }
  return result;
}

/// Splits a request URL (absolute, absolute path or service-root relative) into the decoded
/// resource path relative to `serviceRoot` and the decoded query options.
void splitServiceUrl(string url, string serviceRoot, out string path, out string[string] query) {
  // strip scheme and authority
  foreach (scheme; ["http://", "https://"]) {
    if (url.startsWith(scheme)) {
      auto slash = url.indexOf('/', scheme.length);
      url = slash < 0 ? "/" : url[slash .. $];
    }
  }

  auto q = url.indexOf('?');
  auto rawPath = q < 0 ? url : url[0 .. q];
  query = q < 0 ? null : parseQueryString(url[q + 1 .. $]);

  auto root = serviceRoot.length && serviceRoot[$ - 1] == '/' ? serviceRoot[0 .. $ - 1] : serviceRoot;
  if (rawPath.startsWith(root ~ "/") || rawPath == root)
    rawPath = rawPath[root.length .. $];
  while (rawPath.startsWith("/"))
    rawPath = rawPath[1 .. $];

  try {
    path = urlDecode(rawPath);
  } catch (Exception e) {
    throw badRequest("Invalid URL encoding in path: " ~ e.msg);
  }
}

///
unittest {
  string path;
  string[string] query;
  splitServiceUrl("/odata/v4/Users('USR%2D001')?$select=ID,Name&$filter=Name+eq+'a%20b'", "/odata/v4/", path, query);
  assert(path == "Users('USR-001')");
  assert(query["$select"] == "ID,Name" && query["$filter"] == "Name eq 'a b'");

  splitServiceUrl("BaseBlocks?$top=1", "/odata/v4/", path, query);
  assert(path == "BaseBlocks" && query["$top"] == "1");

  splitServiceUrl("https://host:8080/odata/v4/$metadata", "/odata/v4/", path, query);
  assert(path == "$metadata" && query is null);
}
