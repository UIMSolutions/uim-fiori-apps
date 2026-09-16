module scanner_middleware.application.services.gtt_dispatch_queue;

import std.datetime : Clock;

import scanner_middleware.domain.entities.scan_event : ScanEvent;
import scanner_middleware.domain.ports : SapGttGateway;

struct GttDispatchItem {
    ScanEvent eventData;
    size_t attempts;
    bool deadLettered;
    string lastError;
}

struct GttDispatchResult {
    bool forwarded;
    bool deadLettered;
    size_t attempts;
    string message;
}

class GttDispatchQueue {
    private SapGttGateway m_gateway;
    private size_t m_maxAttempts;
    private GttDispatchItem[] m_pending;
    private GttDispatchItem[] m_deadLetters;

    this(SapGttGateway gateway, size_t maxAttempts = 3) {
        m_gateway = gateway;
        m_maxAttempts = maxAttempts > 0 ? maxAttempts : 3;
    }

    GttDispatchResult enqueueAndDispatch(ScanEvent eventData) {
        GttDispatchItem item;
        item.eventData = eventData;
        item.attempts = 0;
        m_pending ~= item;
        return retryPendingForEvent(eventData.eventId);
    }

    size_t retryAllPending() {
        size_t dispatched;
        if (m_pending.length == 0) {
            return 0;
        }

        size_t index = 0;
        while (index < m_pending.length) {
            auto eventId = m_pending[index].eventData.eventId;
            auto result = retryPendingForEvent(eventId);
            if (result.forwarded) {
                dispatched++;
            } else {
                index++;
            }
        }
        return dispatched;
    }

    GttDispatchItem[] getPending() {
        return m_pending.dup;
    }

    GttDispatchItem[] getDeadLetters() {
        return m_deadLetters.dup;
    }

    private GttDispatchResult retryPendingForEvent(string eventId) {
        foreach (idx, ref item; m_pending) {
            if (item.eventData.eventId != eventId) {
                continue;
            }

            while (item.attempts < m_maxAttempts) {
                string gatewayMessage;
                item.attempts++;
                auto ok = m_gateway.forwardScan(item.eventData, gatewayMessage);
                if (ok) {
                    auto result = GttDispatchResult(true, false, item.attempts,
                        "An SAP GTT weitergeleitet: " ~ gatewayMessage);
                    m_pending = m_pending[0 .. idx] ~ m_pending[idx + 1 .. $];
                    return result;
                }
                item.lastError = gatewayMessage;
            }

            item.deadLettered = true;
            m_deadLetters ~= item;
            auto result = GttDispatchResult(false, true, item.attempts,
                "In DLQ verschoben: " ~ item.lastError);
            m_pending = m_pending[0 .. idx] ~ m_pending[idx + 1 .. $];
            return result;
        }

        return GttDispatchResult(false, false, 0, "Event nicht in Queue gefunden");
    }
}

unittest {
    import scanner_middleware.domain.ports : SapGttGateway;

    class FlakyGateway : SapGttGateway {
        private size_t m_failures;

        this(size_t failures) {
            m_failures = failures;
        }

        override bool forwardScan(ScanEvent eventData, out string message) {
            if (m_failures > 0) {
                m_failures--;
                message = "temporary error";
                return false;
            }

            message = "ok";
            return true;
        }
    }

    auto eventData = ScanEvent("e1", "s1", "m1", 1, "l1", Clock.currTime(), "{}");

    {
        auto queue = new GttDispatchQueue(new FlakyGateway(1), 3);
        auto result = queue.enqueueAndDispatch(eventData);
        assert(result.forwarded);
        assert(!result.deadLettered);
        assert(queue.getPending().length == 0);
        assert(queue.getDeadLetters().length == 0);
    }

    {
        auto queue = new GttDispatchQueue(new FlakyGateway(5), 2);
        auto result = queue.enqueueAndDispatch(eventData);
        assert(!result.forwarded);
        assert(result.deadLettered);
        assert(queue.getPending().length == 0);
        assert(queue.getDeadLetters().length == 1);
    }
}
