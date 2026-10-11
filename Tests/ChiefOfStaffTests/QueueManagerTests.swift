import XCTest
@testable import ChiefOfStaff

final class QueueManagerTests: XCTestCase {

    func testEnqueueFetchAndDequeueCycle() {
        let manager = QueueManager.shared
        let testPayload = CapturePayload(
            category: .brainstorm,
            title: "Test Enqueue Note",
            content: "Automated test body content",
            visibility: "private"
        )

        // 1. Enqueue
        let enqueued = manager.enqueue(testPayload)
        XCTAssertTrue(enqueued, "Payload should be enqueued successfully to local disk.")

        // 2. Fetch
        let pending = manager.fetchAllPendingPayloads()
        XCTAssertTrue(
            pending.contains(where: { $0.id == testPayload.id }),
            "Pending queue should contain the enqueued payload."
        )

        // 3. Dequeue
        manager.dequeue(id: testPayload.id)
        let updatedPending = manager.fetchAllPendingPayloads()
        XCTAssertFalse(
            updatedPending.contains(where: { $0.id == testPayload.id }),
            "Payload should be removed from disk after dequeuing."
        )
    }
}
