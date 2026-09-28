//
//  EmptyResponseTests.swift
//

import XCTest
@testable import Common

final class EmptyResponseTests: MockedSessionTestCase {

    private struct Item: Decodable {
        let id: Int
    }

    func test_204WithoutABody_succeeds() async throws {
        respond(statusCode: 204, body: Data())

        let response: EmptyResponse = try await HTTPService.request(rawRequest())

        XCTAssertEqual(response, EmptyResponse())
    }

    func test_200WithAJSONBody_succeedsAndIgnoresIt() async throws {
        respond(statusCode: 200, body: Data(#"{"id": 1, "name": "ignored"}"#.utf8))

        let response: EmptyResponse = try await HTTPService.request(rawRequest())

        XCTAssertEqual(response, EmptyResponse())
    }

    func test_callbackPath_204_deliversSuccess() async {
        respond(statusCode: 204, body: Data())
        let delivered = expectation(description: "the result is delivered")
        nonisolated(unsafe) var outcome: Result<EmptyResponse, NetworkError>?

        HTTPService.request(rawRequest()) { (result: Result<EmptyResponse, NetworkError>) in
            outcome = result
            delivered.fulfill()
        }

        await fulfillment(of: [delivered], timeout: callbackDeliveryTimeout)
        guard case .success = outcome else { return XCTFail("Expected .success, got \(String(describing: outcome))") }
    }

    func test_404_failsWithResponseError() async {
        respond(statusCode: 404, body: Data())

        do {
            let _: EmptyResponse = try await HTTPService.request(rawRequest())
            XCTFail("Expected NetworkError.responseError")
        } catch NetworkError.responseError(let statusCode, _, _) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Expected NetworkError.responseError, got \(error)")
        }
    }

    func test_fieldInsideAnEnvelope_decodesWhateverItHolds() throws {
        struct Envelope: Decodable {
            let status: String
            let data: EmptyResponse
        }
        let body = Data(#"{"status": "ok", "data": {"ignored": [1, 2]}}"#.utf8)

        let envelope = try JSONDecoder().decode(Envelope.self, from: body)

        XCTAssertEqual(envelope.status, "ok")
    }

    func test_modelWithAnEmpty200Body_failsWithDecodingError() async {
        respond(statusCode: 200, body: Data())

        do {
            let _: Item = try await HTTPService.request(rawRequest())
            XCTFail("Expected NetworkError.decodingError")
        } catch NetworkError.decodingError(let statusCode, _) {
            XCTAssertEqual(statusCode, 200)
        } catch {
            XCTFail("Expected NetworkError.decodingError, got \(error)")
        }
    }
}
