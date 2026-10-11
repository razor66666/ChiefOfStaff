import XCTest
@testable import ChiefOfStaff

final class DashboardViewTests: XCTestCase {

    func testQueueManagerBindingInDashboard() {
        let manager = QueueManager.shared
        manager.clearQueue()

        let testPayload = CapturePayload(
            title: "Dashboard Bind Test",
            content: "Testing queue counter binding",
            visibility: "private"
        )

        let initialCount = manager.pendingQueueCount
        manager.enqueue(testPayload)

        XCTAssertEqual(manager.pendingQueueCount, initialCount + 1)

        manager.dequeue(id: testPayload.id)
        XCTAssertEqual(manager.pendingQueueCount, initialCount)
    }
}
