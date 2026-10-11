import XCTest
@testable import ChiefOfStaff

final class NetworkTransportTests: XCTestCase {
    
    func testSendPayloadSuccessResponse() async throws {
        let transport = NetworkTransport.shared
        let testPayload = CapturePayload(
            category: .inbox,
            title: "Network Test Note",
            content: "Testing mock HTTP dispatch",
            visibility: "public"
        )
        
        // Setup mock response handler (HTTP 200 OK)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }
        
        // Execute dispatch test
        let success = await transport.sendPayload(testPayload)
        XCTAssertTrue(success, "NetworkTransport should return true on 200 OK HTTP response.")
    }
}