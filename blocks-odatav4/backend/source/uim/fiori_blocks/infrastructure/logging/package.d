/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.logging;

/// Technical logging based on vibe.core.log (replaces the former writeln debugging output).
public import vibe.core.log : logDebug, logDiagnostic, logInfo, logWarn, logError;

import vibe.core.log : LogLevel, setLogLevel;

@safe:

/// Sets the global log level from a configuration value ("debug", "info", "warn", "error", "none").
void configureLogging(string level) {
  switch (level) {
  case "trace":
    setLogLevel(LogLevel.trace);
    break;
  case "debug":
    setLogLevel(LogLevel.debug_);
    break;
  case "diagnostic":
    setLogLevel(LogLevel.diagnostic);
    break;
  case "warn", "warning":
    setLogLevel(LogLevel.warn);
    break;
  case "error":
    setLogLevel(LogLevel.error);
    break;
  case "none":
    setLogLevel(LogLevel.none);
    break;
  default:
    setLogLevel(LogLevel.info);
  }
}
