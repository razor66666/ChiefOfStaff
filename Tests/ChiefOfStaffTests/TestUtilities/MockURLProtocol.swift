import Foundation

public class MockURLProtocol: URLProtocol {
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is not set.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(this, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                client?.urlProtocol(this, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(this)
        } catch {
            client?.urlProtocol(this, didFailWithError: error)
        }
    }

    override public func stopLoading() {}
}