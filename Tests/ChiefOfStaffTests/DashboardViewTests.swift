import XCTest
@testable import ChiefOfStaff

final class DashboardViewTests: XCTestCase {
    
    func testQueueManagerBindingInDashboard() {
        let manager = QueueManager.shared
        let testPayload = CapturePayload(
            title: "Dashboard Bind Test",
            content: "Testing queue counter binding",
            visibility: "private"
        )
        
        let initialCount = manager.pendingQueueCount
        manager.enqueue(testPayload)
        
        XCTAssertEqual(manager.pendingQueueCount, initialCount + 1, "Dashboard queue state should increment when payload is enqueued.")
        
        manager.dequeue(id: testPayload.id)
        XCTAssertEqual(manager.pendingQueueCount, initialCount, "Dashboard queue state should decrement when payload is dequeued.")
    }
}