//
//  LocalAuthenticationManager.swift
//

import LocalAuthentication

// MARK: - LocalAuthenticationType
/// Represents the type of local authentication available on the device.
public enum LocalAuthenticationType: Stringable {

    /// Biometric authentication (FaceID, TouchID, etc.).
    case biometry(BiometryType)

    /// No authentication available or enabled.
    case none

    /// Device passcode authentication.
    case passcode

    /// Specific types of biometric authentication.
    public enum BiometryType: Stringable {
        /// Face ID.
        case faceId
        /// Optic ID.
        case opticId
        /// Touch ID.
        case touchId

        public var asString: String {
            switch self {
            case .faceId: "FaceID"
            case .opticId: "OpticID"
            case .touchId: "TouchID"
            }
        }
    }

    public var asString: String {
        switch self {
        case .biometry(let type): type.asString
        case .none: "None"
        case .passcode: "Passcode"
        }
    }
}

// MARK: - LocalAuthenticationManagerProtocol
/// Protocol defining the interface for local authentication management.
public protocol LocalAuthenticationManagerProtocol: AnyObject {

    /// The type of biometry available (if any).
    var biometryType: LocalAuthenticationType.BiometryType? { get }

    /// Whether the device can currently authenticate the user.
    var canAuthenticate: Bool { get }

    /// Whether biometric authentication is supported and enrolled on this device.
    var isBiometricAuthenticationSupported: Bool { get }

    /// The primary type of local authentication available.
    var localAuthenticationType: LocalAuthenticationType { get }

    /// Attempts to authenticate the user using the available method.
    /// - Parameter result: Completion handler returning `true` if successful.
    func authenticate(result: @escaping Handler<Bool>)

    /// Attempts to authenticate the user using the available method, and tells why it failed.
    ///
    /// Returns when the user authenticates. Otherwise it throws an `LAError` whose `code` is the reason, such as
    /// `.userCancel`, `.userFallback` or `.biometryLockout`. A conformer that doesn't implement it gets one built on
    /// `authenticate(result:)`, which throws `.authenticationFailed` for `false`.
    func authenticate() async throws
}

// MARK: - Default Implementation
extension LocalAuthenticationManagerProtocol {
    public func authenticate() async throws {
        let succeeded = await withCheckedContinuation { continuation in
            authenticate { continuation.resume(returning: $0) }
        }
        guard succeeded else { throw LAError(.authenticationFailed) }
    }
}

// MARK: - LocalAuthenticationManager
/// Manages local authentication using `LocalAuthentication` framework.
final public class LocalAuthenticationManager {
    private let cancelTitle: String?
    private let reason: String
    private let contextFactory: () -> LAContext

    /// - Parameters:
    ///   - cancelTitle: Label for the cancel button. Pass `nil` to use the system default.
    ///   - reason: The localized string explaining why authentication is needed.
    public init(cancelTitle: String? = nil, reason: String = "Authentication is required.") {
        self.cancelTitle = cancelTitle
        self.reason = reason
        contextFactory = LAContext.init
    }

    /// Takes the contexts it evaluates from `contextFactory`, so tests can answer without a prompt.
    init(cancelTitle: String? = nil, reason: String = "Authentication is required.", contextFactory: @escaping () -> LAContext) {
        self.cancelTitle = cancelTitle
        self.reason = reason
        self.contextFactory = contextFactory
    }

    /// Creates a fresh LAContext per call so biometric enrollment changes are always reflected.
    private func makeContext() -> LAContext {
        contextFactory().with {
            if let cancelTitle { $0.localizedCancelTitle = cancelTitle }
        }
    }
}

// MARK: - LocalAuthenticationManagerProtocol
extension LocalAuthenticationManager: LocalAuthenticationManagerProtocol {
    private var canAuthenticateWithBiometrics: Bool {
        var error: NSError?
        return makeContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometryType: LocalAuthenticationType.BiometryType? {
        let ctx = makeContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return nil }
        switch ctx.biometryType {
        case .faceID: return .faceId
        case .opticID: return .opticId
        case .touchID: return .touchId
        default: return nil
        }
    }

    public var canAuthenticate: Bool {
        var error: NSError?
        return makeContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    public var isBiometricAuthenticationSupported: Bool { canAuthenticateWithBiometrics }

    public var localAuthenticationType: LocalAuthenticationType {
        let ctx = makeContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            var err2: NSError?
            return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err2) ? .passcode : .none
        }
        switch ctx.biometryType {
        case .faceID: return .biometry(.faceId)
        case .opticID: return .biometry(.opticId)
        case .touchID: return .biometry(.touchId)
        default:
            var err2: NSError?
            return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err2) ? .passcode : .none
        }
    }

    public func authenticate(result: @escaping Handler<Bool>) {
        let ctx = makeContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            dispatchOnMain { result(false) }
            return
        }
        ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            dispatchOnMain { result(error.isNil ? success : false) }
        }
    }

    public func authenticate() async throws {
        let context = makeContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw error ?? LAError(.authenticationFailed)
        }
        guard try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) else {
            throw LAError(.authenticationFailed)
        }
    }
}
