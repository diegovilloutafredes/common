//
//  HTTPServiceTests.swift
//

import XCTest
@testable import Common

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    // Returns URLResponse (not HTTPURLResponse) so tests can deliver a non-HTTP response
    // to exercise the `noDataReceived` guard. HTTPURLResponse is a URLResponse subtype,
    // so existing handlers that build an HTTPURLResponse still satisfy this signature.
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private struct TestItem: Codable, Equatable {
    let id: Int
    let name: String
}

private enum TestEndpoint: URLRequestConvertible {
    case get

    func asURLRequest() throws -> URLRequest {
        URLRequest(url: URL(string: "https://test.example.com/items")!)
    }
}

// MARK: - HTTPServiceTests

final class HTTPServiceTests: XCTestCase {

    private var originalSession: URLSession!

    override func setUp() {
        super.setUp()
        originalSession = HTTPService.defaultSession
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        HTTPService.defaultSession = URLSession(configuration: config)
        MockURLProtocol.requestHandler = nil
    }

    override func tearDown() {
        HTTPService.defaultSession = originalSession
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - 200 success decodes correctly

    func test_request_200_decodesResponse() async throws {
        let expected = TestItem(id: 1, name: "Widget")
        MockURLProtocol.requestHandler = { _ in
            let data = try JSONEncoder().encode(expected)
            let response = HTTPURLResponse(
                url: URL(string: "https://test.example.com/items")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let result: TestItem = try await HTTPService.request(TestEndpoint.get)
        XCTAssertEqual(result, expected)
    }

    // MARK: - 4xx returns responseError with correct statusCode

    func test_request_4xx_returnsResponseError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.example.com/items")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONSerialization.data(withJSONObject: ["message": "not found"])
            return (response, data)
        }

        do {
            let _: TestItem = try await HTTPService.request(TestEndpoint.get)
            XCTFail("Expected NetworkError.responseError")
        } catch NetworkError.responseError(let statusCode, let jsonObject, _) {
            XCTAssertEqual(statusCode, 404)
            // The error body must be parsed into jsonObject — this is
            // responseError(from:statusCode:)'s entire job.
            XCTAssertEqual(jsonObject["message"] as? String, "not found")
        }
    }

    // MARK: - 2xx with undecodable body returns decodingError

    /// The most common real-world client failure: the server says 200 but the
    /// body doesn't match the model. Must surface as `.decodingError`, not a
    /// generic response error and never a silent success.
    func test_request_200_undecodableBody_throwsDecodingError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("not json".utf8))
        }

        do {
            let _: TestItem = try await HTTPService.request(TestEndpoint.get)
            XCTFail("Expected NetworkError.decodingError")
        } catch NetworkError.decodingError(let statusCode, _) {
            XCTAssertEqual(statusCode, 200)
        }
    }

    // MARK: - Non-HTTP response returns noDataReceived

    func test_request_nonHTTPResponse_returnsNoDataReceived() async throws {
        // Deliver a plain URLResponse (not HTTPURLResponse) — `request` casts via
        // `response as? HTTPURLResponse` and throws `.noDataReceived` when that fails.
        MockURLProtocol.requestHandler = { request in
            let response = URLResponse(
                url: request.url!,
                mimeType: "image/png",
                expectedContentLength: 1,
                textEncodingName: nil
            )
            return (response, Data([0x1]))
        }

        do {
            let _: TestItem = try await HTTPService.request(TestEndpoint.get)
            XCTFail("Expected NetworkError.noDataReceived")
        } catch NetworkError.noDataReceived {
            // pass — non-HTTP response correctly mapped to noDataReceived
        }
    }

    // MARK: - Network error returns requestError

    func test_request_networkError_returnsRequestError() async throws {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: TestItem = try await HTTPService.request(TestEndpoint.get)
            XCTFail("Expected NetworkError.requestError")
        } catch NetworkError.requestError {
            // pass
        }
    }

    // MARK: - defaultTimeoutInterval is applied to the dispatched URLRequest

    func test_request_appliesDefaultTimeoutInterval() async throws {
        let customTimeout: TimeInterval = 42
        let originalTimeout = HTTPService.defaultTimeoutInterval
        HTTPService.defaultTimeoutInterval = customTimeout
        defer { HTTPService.defaultTimeoutInterval = originalTimeout }

        var capturedTimeout: TimeInterval?
        MockURLProtocol.requestHandler = { request in
            capturedTimeout = request.timeoutInterval
            let data = try JSONEncoder().encode(TestItem(id: 0, name: "t"))
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let _: TestItem = try await HTTPService.request(TestEndpoint.get)
        XCTAssertEqual(capturedTimeout, customTimeout)
    }

    // MARK: - Callback overload — cancellation

    func test_callbackRequest_cancelledMidFlight_doesNotFireHandler() async throws {
        // Deterministic coordination instead of racing wall-clock sleeps: the
        // mock BLOCKS on a semaphore that is signalled only AFTER task.cancel()
        // returns, so the response can never win the race on a loaded CI box.
        let responseGate = DispatchSemaphore(value: 0)
        MockURLProtocol.requestHandler = { request in
            responseGate.wait()
            let data = try JSONEncoder().encode(TestItem(id: 1, name: "Widget"))
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        nonisolated(unsafe) var handlerFired = false
        let task: Task<Void, Never> = HTTPService.request(TestEndpoint.get) { (_: Result<TestItem, NetworkError>) in
            handlerFired = true
        }

        try await Task.sleep(nanoseconds: 50_000_000) // let the request start
        task.cancel()
        responseGate.signal() // release the mock only after cancellation

        await task.value // the wrapper task has fully finished deciding
        try await Task.sleep(nanoseconds: 100_000_000) // drain any MainActor hop

        XCTAssertFalse(handlerFired, "the handler must not fire after cancellation")
    }

    func test_callbackRequest_completesNormally_firesHandler() async throws {
        let expected = TestItem(id: 7, name: "Foo")
        MockURLProtocol.requestHandler = { request in
            let data = try JSONEncoder().encode(expected)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let handlerCalled = expectation(description: "result handler should fire")
        nonisolated(unsafe) var received: TestItem?

        _ = HTTPService.request(TestEndpoint.get) { (result: Result<TestItem, NetworkError>) in
            // The callback contract is MainActor delivery via `Task { @MainActor in ... }`
            // — NOT DispatchQueue.main.async, which Xcode 26 does not drain during
            // `await fulfillment(of:)` and which is a separate scheduler from @MainActor.
            // Do not "simplify" this assertion away; it pins the delivery thread.
            XCTAssertTrue(Thread.isMainThread, "callback results must be delivered on the main thread")
            if case .success(let value) = result { received = value }
            handlerCalled.fulfill()
        }

        // Generous timeout: the callback hops through Task { @MainActor } and a
        // loaded CI runner can take seconds to schedule it. Fulfillment returns
        // as soon as the expectation fires, so the pass path stays fast.
        await fulfillment(of: [handlerCalled], timeout: 10.0)
        XCTAssertEqual(received, expected)
    }

    /// A failing request must still fire the handler — with the mapped error.
    /// Guards the regression where the callback wrapper returns early on error
    /// and the caller waits forever.
    func test_callbackRequest_failure_firesHandlerWithNetworkError() async throws {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let handlerCalled = expectation(description: "result handler should fire on failure")
        nonisolated(unsafe) var receivedError: NetworkError?

        _ = HTTPService.request(TestEndpoint.get) { (result: Result<TestItem, NetworkError>) in
            if case .failure(let error) = result { receivedError = error }
            handlerCalled.fulfill()
        }

        await fulfillment(of: [handlerCalled], timeout: 10.0)
        guard case .requestError = receivedError else {
            return XCTFail("Expected .requestError, got \(String(describing: receivedError))")
        }
    }

    // MARK: - Multipart upload

    func test_upload_multipart_setsContentTypeAndAssemblesBody() async throws {
        var multipart = MultipartRequest(boundary: "test-boundary")
        multipart.add(key: "field", value: "value1")
        multipart.add(key: "file", fileName: "a.txt", fileMimeType: "text/plain", fileData: Data("hello".utf8))

        var capturedContentType: String?
        var capturedBody: Data?
        MockURLProtocol.requestHandler = { request in
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            // URLSession hands URLProtocol the body as a stream, not httpBody.
            if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var body = Data()
                let bufferSize = 4096
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: bufferSize)
                    guard read > 0 else { break }
                    body.append(buffer, count: read)
                }
                capturedBody = body
            }
            let data = try JSONEncoder().encode(TestItem(id: 1, name: "ok"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let result: TestItem = try await HTTPService.upload(multipart: multipart, to: TestEndpoint.get)

        XCTAssertEqual(result.name, "ok")
        XCTAssertEqual(capturedContentType, "multipart/form-data; boundary=test-boundary")
        let body = String(decoding: try XCTUnwrap(capturedBody), as: UTF8.self)
        XCTAssertTrue(body.contains("--test-boundary"), "body must open with the boundary separator")
        XCTAssertTrue(body.contains("Content-Disposition: form-data; name=\"field\""))
        XCTAssertTrue(body.contains("value1"))
        XCTAssertTrue(body.contains("filename=\"a.txt\""))
        XCTAssertTrue(body.contains("Content-Type: text/plain"))
        XCTAssertTrue(body.contains("hello"))
    }

    // MARK: - 5xx returns responseError

    func test_request_5xx_returnsResponseError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.example.com/items")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: TestItem = try await HTTPService.request(TestEndpoint.get)
            XCTFail("Expected NetworkError.responseError")
        } catch NetworkError.responseError(let statusCode, let jsonObject, _) {
            XCTAssertEqual(statusCode, 500)
            // Empty body → empty jsonObject (the non-JSON default branch).
            XCTAssertTrue(jsonObject.isEmpty)
        }
    }
}
