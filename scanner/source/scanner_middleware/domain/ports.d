module scanner_middleware.domain.ports;

import scanner_middleware.domain.entities.scan_event : ScanEvent;

interface ScanRepository {
    void save(ScanEvent eventData);
    ScanEvent[] listRecent(size_t limit = 100);
}

interface SapGttGateway {
    bool forwardScan(ScanEvent eventData, out string message);
}
