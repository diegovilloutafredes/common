//
//  MockedSessionTestCase.swift
//

import XCTest
@testable import Common

/// Routes `HTTPService.defaultSession` through `MockURLProtocol` for each test, and restores the session, the default
/// timeout and the handler afterwards.
class MockedSessionTestCase: XCTestCase {

    private var originalSession: URLSession!
    private var originalTimeout: TimeInterval = .zero

    override func setUp() {
        super.setUp()
        originalSession = HTTPService.defaultSession
        originalTimeout = HTTPService.defaultTimeoutInterval
        HTTPService.defaultSession = Self.session(with: MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
    }

    override func tearDown() {
        HTTPService.defaultSession = originalSession
        HTTPService.defaultTimeoutInterval = originalTimeout
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    /// A session whose requests all go to `protocolClass`.
    static func session(with protocolClass: URLProtocol.Type) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [protocolClass]
        return URLSession(configuration: configuration)
    }

    /// Answers every request on the default session with `statusCode` and `body`, passing each one to `capture` first.
    func respond(statusCode: Int = 200, body: Data = Data("{}".utf8), capture: ((URLRequest) -> Void)? = nil) {
        MockURLProtocol.requestHandler = { request in
            capture?(request)
            return (HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, body)
        }
    }
}

/// A request that is a plain `URLRequest`, not an `Endpoint`.
func rawRequest(timeoutInterval: TimeInterval? = nil) -> URLRequest {
    var request = URLRequest(url: URL(string: "https://test.example.com/items")!)
    if let timeoutInterval { request.timeoutInterval = timeoutInterval }
    return request
}
