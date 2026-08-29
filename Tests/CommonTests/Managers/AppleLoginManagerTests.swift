//
//  AppleLoginManagerTests.swift
//

import AuthenticationServices
import UIKit
import XCTest
@testable import Common

@MainActor
final class AppleLoginManagerTests: XCTestCase {

    // MARK: - JWT decoding

    private func token(payload: String) -> String {
        let header = base64url("{\"alg\":\"RS256\"}")
        return "\(header).\(base64url(payload)).signature"
    }

    /// Apple's identity token uses base64url without padding.
    private func base64url(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    func test_decode_returnsPayloadDictionary() throws {
        // 30 bytes → base64 needs padding; proves the padding restoration path.
        let payload = try AppleLoginManager.decode(jwtToken: token(payload: "{\"sub\":\"001\",\"email\":\"a@b.c\"}"))

        XCTAssertEqual(payload["sub"] as? String, "001")
        XCTAssertEqual(payload["email"] as? String, "a@b.c")
    }

    func test_decode_withFewerThanThreeSegments_throwsBadToken() {
        XCTAssertThrowsError(try AppleLoginManager.decode(jwtToken: "header.payload")) { error in
            XCTAssertEqual(error as? AppleLoginError, .badToken)
        }
    }

    func test_decode_withInvalidBase64Payload_throwsBadToken() {
        XCTAssertThrowsError(try AppleLoginManager.decode(jwtToken: "h.@@@.s")) { error in
            XCTAssertEqual(error as? AppleLoginError, .badToken)
        }
    }

    func test_decode_withNonObjectPayload_throwsMalformedPayload() {
        XCTAssertThrowsError(try AppleLoginManager.decode(jwtToken: token(payload: "[1,2,3]"))) { error in
            XCTAssertEqual(error as? AppleLoginError, .malformedPayload)
        }
    }

    func test_appleLoginError_describesEveryCase() {
        for error in [AppleLoginError.badToken, .malformedPayload, .alreadyInProgress] {
            XCTAssertFalse(error.localizedDescription.isEmpty, "\(error) must be presentable")
        }
    }

    // MARK: - Presentation anchor

    func test_presentationAnchor_withoutContextWindow_returnsAWindowInsteadOfCrashing() {
        let manager = AppleLoginManager()
        let controller = ASAuthorizationController(authorizationRequests: [ASAuthorizationAppleIDProvider().createRequest()])

        let anchor = manager.presentationAnchor(for: controller)

        XCTAssertNotNil(anchor)
    }

    // MARK: - Flow lifecycle

    func test_performLogin_doesNotRetainContext() {
        let manager = AppleLoginManager()
        weak var weakContext: UIViewController?

        autoreleasepool {
            let context = UIViewController()
            weakContext = context
            manager.performLogin(from: context) { _ in }
        }

        XCTAssertNil(weakContext, "the manager must not keep the anchor view controller alive")
    }

    func test_performLogin_whilePending_failsWithAlreadyInProgress() {
        let manager = AppleLoginManager()
        let context = UIViewController()
        manager.performLogin(from: context) { _ in }
        var second: Result<AppleLoginCredentials, Error>?

        manager.performLogin(from: context) { second = $0 }

        guard case .failure(let error)? = second else { return XCTFail("second request must fail synchronously") }
        XCTAssertEqual(error as? AppleLoginError, .alreadyInProgress)
    }

    // Pin: a delivered outcome must clear the pending state so the next login is accepted.
    func test_errorCallback_deliversFailureAndAllowsNextLogin() {
        let manager = AppleLoginManager()
        let context = UIViewController()
        var first: Result<AppleLoginCredentials, Error>?
        manager.performLogin(from: context) { first = $0 }
        let controller = ASAuthorizationController(authorizationRequests: [ASAuthorizationAppleIDProvider().createRequest()])

        manager.authorizationController(controller: controller, didCompleteWithError: ASAuthorizationError(.canceled))
        var second: Result<AppleLoginCredentials, Error>?
        manager.performLogin(from: context) { second = $0 }

        guard case .failure? = first else { return XCTFail("the error must reach the first handler") }
        XCTAssertNil(second, "a fresh login after completion must be accepted, not rejected as in-progress")
    }
}
