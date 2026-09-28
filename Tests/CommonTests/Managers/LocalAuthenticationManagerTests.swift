//
//  LocalAuthenticationManagerTests.swift
//

import LocalAuthentication
import XCTest
@testable import Common

final class LocalAuthenticationManagerTests: XCTestCase {

    /// Answers the policy check and the evaluation as configured, without showing a prompt.
    private final class StubContext: LAContext {
        var checkFailure: LAError.Code?
        var evaluationResult = true
        var evaluationFailure: LAError.Code?
        private(set) var evaluationCount = 0

        override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
            guard let checkFailure else { return true }
            error?.pointee = NSError(domain: LAErrorDomain, code: checkFailure.rawValue)
            return false
        }

        override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping @Sendable (Bool, (any Error)?) -> Void) {
            evaluationCount += 1
            reply(evaluationResult, evaluationFailure.map { NSError(domain: LAErrorDomain, code: $0.rawValue) })
        }
    }

    /// Implements only the callback, as conformers written before `authenticate()` do.
    private final class CallbackOnlyManager: LocalAuthenticationManagerProtocol {
        let answer: Bool
        init(answer: Bool) { self.answer = answer }
        var biometryType: LocalAuthenticationType.BiometryType? { nil }
        var canAuthenticate: Bool { true }
        var isBiometricAuthenticationSupported: Bool { false }
        var localAuthenticationType: LocalAuthenticationType { .none }
        func authenticate(result: @escaping Handler<Bool>) { result(answer) }
    }

    private func authenticate(with context: StubContext) async throws {
        try await LocalAuthenticationManager(contextFactory: { context }).authenticate()
    }

    private func assertThrows(_ code: LAError.Code, _ operation: () async throws -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            try await operation()
            XCTFail("Expected LAError \(code)", file: file, line: line)
        } catch let error as LAError {
            XCTAssertEqual(error.code, code, file: file, line: line)
        } catch {
            XCTFail("Expected an LAError, got \(error)", file: file, line: line)
        }
    }

    // MARK: - LocalAuthenticationManager

    func test_success_returns() async throws {
        let context = StubContext()

        try await authenticate(with: context)

        XCTAssertEqual(context.evaluationCount, 1)
    }

    func test_userCancel_throwsThatCode() async {
        let context = StubContext()
        context.evaluationResult = false
        context.evaluationFailure = .userCancel

        await assertThrows(.userCancel) { try await authenticate(with: context) }
    }

    func test_failedPolicyCheck_throwsItsCodeWithoutEvaluating() async {
        let context = StubContext()
        context.checkFailure = .passcodeNotSet

        await assertThrows(.passcodeNotSet) { try await authenticate(with: context) }
        XCTAssertEqual(context.evaluationCount, .zero, "no prompt is shown when the policy can't be evaluated")
    }

    func test_falseWithoutAnError_throwsAuthenticationFailed() async {
        let context = StubContext()
        context.evaluationResult = false

        await assertThrows(.authenticationFailed) { try await authenticate(with: context) }
    }

    // MARK: - Conformers that implement only the callback

    func test_callbackOnlyConformer_false_throwsAuthenticationFailed() async {
        let manager: LocalAuthenticationManagerProtocol = CallbackOnlyManager(answer: false)

        await assertThrows(.authenticationFailed) { try await manager.authenticate() }
    }

    func test_callbackOnlyConformer_true_returns() async throws {
        let manager: LocalAuthenticationManagerProtocol = CallbackOnlyManager(answer: true)

        try await manager.authenticate()
    }
}
