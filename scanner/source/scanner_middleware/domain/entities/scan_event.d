module scanner_middleware.domain.entities.scan_event;

import std.datetime : SysTime;

struct ScanEvent {
    string eventId;
    string scannerId;
    string materialNumber;
    size_t quantity;
    string location;
    SysTime scannedAt;
    string rawPayload;
}
