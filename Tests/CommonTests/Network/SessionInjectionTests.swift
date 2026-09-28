//
//  SessionInjectionTests.swift
//

import XCTest
@testable import Common

/// Answers every request sent through a session it is registered on. The default session's `MockURLProtocol` has no
/// handler in these tests unless one sets it, so a success proves which session carried the request.
final class CustomSessionURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestCount = 0
    nonisolated(unsafe) static var body = Data("{}".utf8)

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requestCount += 1
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class SessionInjectionTests: MockedSessionTestCase {

    private struct Item: Decodable, Equatable {
        let id: Int
    }

    /// Decodes only with keys kept as written: the default snake-case decoder maps `legacy_id` to `legacyId`.
    private struct LegacyItem: Decodable {
        let legacy_id: Int
    }

    /// Signals `decoded` from the request's own task, the moment its response is decoded.
    private struct DecodeSignal: Decodable {
        nonisolated(unsafe) static var decoded = DispatchSemaphore(value: 0)
        init(from decoder: Decoder) throws { Self.decoded.signal() }
    }

    private final class AsyncClient: AsyncBaseClient {}

    private final class CallbackClient: BaseClient {
        func fetchThroughSession(result: @escaping NetworkResultHandler<DecodeSignal>) {
            request(rawRequest(), urlSession: HTTPService.defaultSession, result: result)
        }
        func fetchFirst(result: @escaping NetworkResultHandler<Item>) { request(rawRequest(), result: result) }
        func fetchSecond(result: @escaping NetworkResultHandler<Item>) { request(rawRequest(), result: result) }
        func uploadFirst(result: @escaping NetworkResultHandler<Item>) {
            upload(multipart: MultipartRequest(boundary: "b"), to: rawRequest(), result: result)
        }
        func uploadSecond(result: @escaping NetworkResultHandler<Item>) {
            upload(multipart: MultipartRequest(boundary: "b"), to: rawRequest(), result: result)
        }
    }

    private var customSession: URLSession!

    override func setUp() {
        super.setUp()
        CustomSessionURLProtocol.requestCount = 0
        CustomSessionURLProtocol.body = Data(#"{"id": 1}"#.utf8)
        customSession = Self.session(with: CustomSessionURLProtocol.self)
    }

    // MARK: - Sessions

    func test_asyncClient_withItsOwnSession_dispatchesThroughIt() async throws {
        let item: Item = try await AsyncClient().request(rawRequest(), urlSession: customSession)

        XCTAssertEqual(item, Item(id: 1))
        XCTAssertEqual(CustomSessionURLProtocol.requestCount, 1)
    }

    func test_existingCall_goesThroughTheDefaultSession() async throws {
        respond(body: Data(#"{"id": 2}"#.utf8))

        let item: Item = try await AsyncClient().request(rawRequest())

        XCTAssertEqual(item, Item(id: 2))
        XCTAssertEqual(CustomSessionURLProtocol.requestCount, 0)
    }

    func test_upload_throughACustomSession_dispatchesThroughIt() async throws {
        let item: Item = try await HTTPService.upload(multipart: MultipartRequest(boundary: "b"), to: rawRequest(), urlSession: customSession)

        XCTAssertEqual(item, Item(id: 1))
        XCTAssertEqual(CustomSessionURLProtocol.requestCount, 1)
    }

    func test_callbackUpload_throughACustomSession_dispatchesThroughIt() async {
        let delivered = expectation(description: "the upload delivers")
        nonisolated(unsafe) var outcome: Result<Item, NetworkError>?

        HTTPService.upload(multipart: MultipartRequest(boundary: "b"), to: rawRequest(), urlSession: customSession) { (result: Result<Item, NetworkError>) in
            outcome = result
            delivered.fulfill()
        }

        await fulfillment(of: [delivered], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(try outcome?.get(), Item(id: 1))
        XCTAssertEqual(CustomSessionURLProtocol.requestCount, 1)
    }

    func test_existingUpload_goesThroughTheDefaultSession() async throws {
        respond(body: Data(#"{"id": 2}"#.utf8))

        let item: Item = try await HTTPService.upload(multipart: MultipartRequest(boundary: "b"), to: rawRequest())

        XCTAssertEqual(item, Item(id: 2))
        XCTAssertEqual(CustomSessionURLProtocol.requestCount, 0)
    }

    // MARK: - Decoders

    func test_customDecoder_decodesTheResponse() async throws {
        respond(body: Data(#"{"legacy_id": 7}"#.utf8))
        let keysAsWritten = JSONDecoder().keyDecodingStrategy(.useDefaultKeys)

        let asyncItem: LegacyItem = try await AsyncClient().request(rawRequest(), decoder: keysAsWritten)
        XCTAssertEqual(asyncItem.legacy_id, 7)

        let delivered = expectation(description: "the callback request delivers")
        nonisolated(unsafe) var callbackItem: LegacyItem?
        let client = BaseClient()
        client.request(rawRequest(), decoder: keysAsWritten) { (result: Result<LegacyItem, NetworkError>) in
            callbackItem = try? result.get()
            delivered.fulfill()
        }
        await fulfillment(of: [delivered], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(callbackItem?.legacy_id, 7)

        do {
            let _: LegacyItem = try await AsyncClient().request(rawRequest())
            XCTFail("the default snake-case decoder must not read the key as written")
        } catch NetworkError.decodingError {}
    }

    // MARK: - One in-flight request per function

    @MainActor
    func test_sessionTakingRequest_twiceFromOneFunction_onlyTheSecondDelivers() async {
        DecodeSignal.decoded = DispatchSemaphore(value: 0)
        respond()
        let client = CallbackClient()
        nonisolated(unsafe) var firstFired = false
        let secondDelivered = expectation(description: "the second request delivers")

        client.fetchThroughSession { _ in firstFired = true }
        XCTAssertEqual(DecodeSignal.decoded.wait(timeout: .now() + callbackDeliveryTimeout), .success, "the first response was never decoded")
        client.fetchThroughSession { _ in secondDelivered.fulfill() }

        await fulfillment(of: [secondDelivered], timeout: callbackDeliveryTimeout)
        for _ in 0..<5 { await Task.yield() }
        XCTAssertFalse(firstFired, "the superseded request must not deliver")
    }

    /// The old entry points forward to the new overloads with the caller's `function`: were the new overload's
    /// `#function` default used instead, both calls would share one key and the second would cancel the first.
    @MainActor
    func test_existingRequests_fromTwoFunctions_bothDeliver() async {
        respond(body: Data(#"{"id": 3}"#.utf8))
        let client = CallbackClient()
        let firstDelivered = expectation(description: "the first request delivers")
        let secondDelivered = expectation(description: "the second request delivers")

        client.fetchFirst { _ in firstDelivered.fulfill() }
        client.fetchSecond { _ in secondDelivered.fulfill() }

        await fulfillment(of: [firstDelivered, secondDelivered], timeout: callbackDeliveryTimeout)
    }

    @MainActor
    func test_existingUploads_fromTwoFunctions_bothDeliver() async {
        respond(body: Data(#"{"id": 3}"#.utf8))
        let client = CallbackClient()
        let firstDelivered = expectation(description: "the first upload delivers")
        let secondDelivered = expectation(description: "the second upload delivers")

        client.uploadFirst { _ in firstDelivered.fulfill() }
        client.uploadSecond { _ in secondDelivered.fulfill() }

        await fulfillment(of: [firstDelivered, secondDelivered], timeout: callbackDeliveryTimeout)
    }
}
