import Foundation

/// Handles dispatching queued payloads over HTTP REST/Webhook endpoints or email workers.
public class NetworkTransport {
    public static let shared = NetworkTransport()
    
    private let ingestEndpoint: URL?
    
    public init() {
        // Reads IngestEndpoint from AppConfig.plist or falls back to default local ingest server
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let endpointString = dict["IngestEndpoint"] as? String {
            self.ingestEndpoint = URL(string: endpointString)
        } else {
            self.ingestEndpoint = URL(string: "https://api.yourdomain.local/v1/ingest")
        }
    }

    /// Iterates through pending local queue payloads and attempts transmission.
    public func flushQueue() async {
        let pending = QueueManager.shared.fetchAllPendingPayloads()
        guard !pending.isEmpty else { return }
        
        print("[NetworkTransport] Beginning queue flush for \(pending.count) payload(s)...")
        
        for payload in pending {
            let success = await sendPayload(payload)
            if success {
                QueueManager.shared.dequeue(id: payload.id)
            } else {
                print("[NetworkTransport] Flush paused: payload \(payload.id) failed transmission. Holding in queue.")
                break // Stop batch flush on network error to preserve sequential order
            }
        }
    }

    /// Transmits a single CapturePayload over HTTPS REST/Webhook.
    public func sendPayload(_ payload: CapturePayload) async -> Bool {
        guard let endpoint = ingestEndpoint else {
            print("[NetworkTransport] Invalid ingest endpoint URL.")
            return false
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15.0
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(payload)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("[NetworkTransport] Payload \(payload.id) dispatched successfully (HTTP \(httpResponse.statusCode)).")
                return true
            } else {
                print("[NetworkTransport] Server returned non-200 response.")
                return false
            }
        } catch {
            print("[NetworkTransport] Network error sending payload \(payload.id): \(error.localizedDescription)")
            return false
        }
    }
}