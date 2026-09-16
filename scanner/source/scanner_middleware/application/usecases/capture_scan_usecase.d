module scanner_middleware.application.usecases.capture_scan_usecase;

import std.datetime : Clock;
import std.string : strip;
import std.uuid : randomUUID;

import scanner_middleware.application.dto.capture_scan_command : CaptureScanCommand;
import scanner_middleware.application.services.gtt_dispatch_queue : GttDispatchQueue;
import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : ScanRepository;

struct CaptureScanResult {
    bool success;
    bool forwardedToSapGtt;
    bool deadLettered;
    size_t dispatchAttempts;
    string message;
    ScanEvent eventData;
}

class CaptureScanUseCase {
    private ScanRepository m_repository;
    private GttDispatchQueue m_dispatchQueue;

    this(ScanRepository repository, GttDispatchQueue dispatchQueue) {
        m_repository = repository;
        m_dispatchQueue = dispatchQueue;
    }

    CaptureScanResult execute(CaptureScanCommand command) {
        if (!isValid(command)) {
            return CaptureScanResult(false, false, false, 0,
                "Ungueltige Scannerdaten", ScanEvent.init);
        }

        auto timestamp = command.hasScannedAt ? command.scannedAt : Clock.currTime();
        auto eventData = ScanEvent(
            randomUUID().toString(),
            command.scannerId.strip,
            command.materialNumber.strip,
            command.quantity,
            command.location.strip,
            timestamp,
            command.rawPayload
        );

        m_repository.save(eventData);

        auto dispatchResult = m_dispatchQueue.enqueueAndDispatch(eventData);
        return CaptureScanResult(
            true,
            dispatchResult.forwarded,
            dispatchResult.deadLettered,
            dispatchResult.attempts,
            dispatchResult.message,
            eventData
        );
    }

    private bool isValid(CaptureScanCommand command) {
        return command.scannerId.strip.length > 0
            && command.materialNumber.strip.length > 0
            && command.quantity > 0;
    }
}

unittest {
    import scanner_middleware.application.services.gtt_dispatch_queue : GttDispatchQueue;
    import scanner_middleware.domain.ports : ScanRepository, SapGttGateway;

    class TestRepository : ScanRepository {
        private ScanEvent[] m_events;

        override void save(ScanEvent eventData) {
            m_events ~= eventData;
        }

        override ScanEvent[] listRecent(size_t limit = 100) {
            return m_events.dup;
        }
    }

    class AlwaysOkGateway : SapGttGateway {
        override bool forwardScan(ScanEvent eventData, out string message) {
            message = "ok";
            return true;
        }
    }

    auto repository = new TestRepository();
    auto queue = new GttDispatchQueue(new AlwaysOkGateway(), 3);
    auto useCase = new CaptureScanUseCase(repository, queue);

    auto invalidResult = useCase.execute(CaptureScanCommand.init);
    assert(!invalidResult.success);

    CaptureScanCommand cmd;
    cmd.scannerId = "HHS-1";
    cmd.materialNumber = "MAT-1";
    cmd.quantity = 2;

    auto result = useCase.execute(cmd);
    assert(result.success);
    assert(result.forwardedToSapGtt);
    assert(result.dispatchAttempts == 1);
    assert(repository.listRecent().length == 1);
}
