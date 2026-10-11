import Foundation

public class QueueManager: ObservableObject {
    public static let shared = QueueManager()
    
    @Published public private(set) var pendingQueueCount: Int = 0
    private var queue: [CapturePayload] = []
    
    public init() {}

    public func enqueue(_ payload: CapturePayload) {
        queue.append(payload)
        pendingQueueCount = queue.count
    }

    public func dequeue(id: UUID) {
        queue.removeAll { $0.id == id }
        pendingQueueCount = queue.count
    }

    public func fetchAllPendingPayloads() -> [CapturePayload] {
        return queue
    }

    /// Resets the queue state (used for testing and system flushes)
    public func clearQueue() {
        queue.removeAll()
        pendingQueueCount = 0
    }
}