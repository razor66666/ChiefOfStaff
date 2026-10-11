import Foundation

/// Handles dispatching queued payloads over HTTP REST/Webhook endpoints.
public class NetworkTransport {
    public static let shared = NetworkTransport()

    /// Configurable session property for unit testing and MockURLProtocol injection
    public var session: URLSession

    private var ingestEndpoint: URL {
        return AppConfig.shared.ingestEndpoint
    }

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Iterates through pending local queue payloads and attempts transmission.
    public func flushQueue() async {
        let pending = QueueManager.shared.fetchAllPendingPayloads()
        guard !pending.isEmpty else { return }

        for payload in pending {
            let success = await sendPayload(payload)
            if success {
                QueueManager.shared.dequeue(id: payload.id)
            } else {
                break // Stop batch flush on network error to preserve order
            }
        }
    }

    /// Transmits a single CapturePayload over HTTPS REST/Webhook.
    public func sendPayload(_ payload: CapturePayload) async -> Bool {
        var request = URLRequest(url: ingestEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15.0

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(payload)
            request.httpBody = jsonData

            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
