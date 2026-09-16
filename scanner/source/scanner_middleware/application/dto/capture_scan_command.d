module scanner_middleware.application.dto.capture_scan_command;

import std.datetime : SysTime;

struct CaptureScanCommand {
    string scannerId;
    string materialNumber;
    size_t quantity;
    string location;
    string rawPayload;
    SysTime scannedAt;
    bool hasScannedAt;
}
