/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.errors;

@safe:

/// Protocol level error with HTTP status and OData error code.
class ODataException : Exception {
  int status;
  string code;

  this(int status, string code, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    this.status = status;
    this.code = code;
    super(msg, file, line);
  }
}

ODataException badRequest(string msg) pure nothrow {
  return new ODataException(400, "BadRequest", msg);
}

ODataException notFound(string msg) pure nothrow {
  return new ODataException(404, "NotFound", msg);
}

ODataException methodNotAllowed(string method, string path) pure nothrow {
  return new ODataException(405, "MethodNotAllowed", "Method " ~ method ~ " is not allowed for '" ~ path ~ "'");
}
