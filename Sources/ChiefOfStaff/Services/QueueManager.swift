import Foundation

public class QueueManager: ObservableObject {
    public static let shared = QueueManager()

    @Published public private(set) var pendingQueueCount: Int = 0
    private var queue: [CapturePayload] = []

    public init() {}

    @discardableResult
    public func enqueue(_ payload: CapturePayload) -> Bool {
        do {
            queue.append(payload)
            pendingQueueCount = queue.count
            return true
        } catch {
            return false
        }
    }

    public func dequeue(id: UUID) {
        queue.removeAll { $0.id == id }
        pendingQueueCount = queue.count
    }

    public func fetchAllPendingPayloads() -> [CapturePayload] {
        return queue
    }

    public func clearQueue() {
        queue.removeAll()
        pendingQueueCount = 0
    }
}
