//
//  NetworkTimeoutTests.swift
//

import XCTest
@testable import Common

final class NetworkTimeoutTests: MockedSessionTestCase {

    private struct TimedEndpoint: Endpoint {
        var timeoutInterval: TimeInterval?
        var baseURL: URL? { URL(string: "https://test.example.com") }
        var path: String { "/items" }
        var headers: HTTPHeaders { [:] }
        var method: HTTPMethod { .post }
        var parameters: Encodable? { nil }
    }

    private struct Empty: Decodable {}

    private var dispatchedTimeout: TimeInterval?

    override func setUp() {
        super.setUp()
        HTTPService.defaultTimeoutInterval = 30
        dispatchedTimeout = nil
        respond { [unowned self] in dispatchedTimeout = $0.timeoutInterval }
    }

    // MARK: - Endpoints

    func test_endpointDeclaringNoTimeout_getsTheDefault() async throws {
        let _: Empty = try await HTTPService.request(TimedEndpoint(timeoutInterval: nil))
        XCTAssertEqual(dispatchedTimeout, 30)
    }

    func test_endpointTimeout_winsOverTheDefault() async throws {
        let _: Empty = try await HTTPService.request(TimedEndpoint(timeoutInterval: 120))
        XCTAssertEqual(dispatchedTimeout, 120)
    }

    func test_endpointDeclaring60Seconds_keepsThem() async throws {
        let _: Empty = try await HTTPService.request(TimedEndpoint(timeoutInterval: 60))
        XCTAssertEqual(dispatchedTimeout, 60, "an endpoint's timeout is exact, even at URLRequest's built-in value")
    }

    func test_uploadToAnEndpoint_usesItsTimeout() async throws {
        let _: Empty = try await HTTPService.upload(multipart: MultipartRequest(boundary: "b"), to: TimedEndpoint(timeoutInterval: 120))
        XCTAssertEqual(dispatchedTimeout, 120)
    }

    func test_endpointsOwnRequest_carriesItsTimeout() {
        XCTAssertEqual(TimedEndpoint(timeoutInterval: 120).urlRequest?.timeoutInterval, 120)
    }

    func test_callbackPath_appliesTheSameRules() async {
        let firstDelivered = expectation(description: "the request without a timeout delivers")
        HTTPService.request(TimedEndpoint(timeoutInterval: nil)) { (_: Result<Empty, NetworkError>) in firstDelivered.fulfill() }
        await fulfillment(of: [firstDelivered], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(dispatchedTimeout, 30)

        let secondDelivered = expectation(description: "the request with a timeout delivers")
        HTTPService.request(TimedEndpoint(timeoutInterval: 120)) { (_: Result<Empty, NetworkError>) in secondDelivered.fulfill() }
        await fulfillment(of: [secondDelivered], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(dispatchedTimeout, 120)
    }

    // MARK: - Raw requests

    func test_rawRequestWithItsOwnTimeout_keepsIt() async throws {
        let _: Empty = try await HTTPService.request(rawRequest(timeoutInterval: 120))
        XCTAssertEqual(dispatchedTimeout, 120)
    }

    func test_rawRequestLeftAtTheBuiltInDefault_getsTheDefault() async throws {
        let _: Empty = try await HTTPService.request(rawRequest())
        XCTAssertEqual(dispatchedTimeout, 30)
    }
}
