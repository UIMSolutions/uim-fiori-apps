module scanner_middleware.infrastructure.repositories.in_memory_scan_repository;

import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : ScanRepository;

class InMemoryScanRepository : ScanRepository {
    private ScanEvent[] m_events;

    override void save(ScanEvent eventData) {
        m_events ~= eventData;
    }

    override ScanEvent[] listRecent(size_t limit = 100) {
        if (m_events.length == 0) {
            return [];
        }

        auto start = m_events.length > limit ? m_events.length - limit : 0;
        return m_events[start .. $].dup;
    }
}
