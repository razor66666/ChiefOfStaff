import XCTest
@testable import ChiefOfStaff

final class CapturePayloadTests: XCTestCase {
    
    func testPayloadJSONEncodingAndDecoding() throws {
        let originalPayload = CapturePayload(
            category: .todo,
            title: "Review Pull Request",
            content: "Check SPM layout and XCTest suites",
            tags: ["devsecops", "swift"],
            visibility: "private"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalPayload)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedPayload = try decoder.decode(CapturePayload.self, from: data)
        
        XCTAssertEqual(originalPayload.id, decodedPayload.id)
        XCTAssertEqual(originalPayload.title, decodedPayload.title)
        XCTAssertEqual(originalPayload.category, decodedPayload.category)
        XCTAssertEqual(originalPayload.visibility, "private")
    }
}