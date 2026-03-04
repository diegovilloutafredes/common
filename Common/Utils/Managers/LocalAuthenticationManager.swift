//
//  LocalAuthenticationManager.swift
//

import LocalAuthentication

// MARK: - LocalAuthenticationType
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
        case .none: "Ninguno"
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
    
    /// Whether biometric authentication is supported on this device.
    var isBiometricAuthenticationSupported: Bool { get }
    
    /// The primary type of local authentication available.
    var localAuthenticationType: LocalAuthenticationType { get }
    
    /// Attempts to authenticate the user using the available method.
    /// - Parameter result: Completion handler returning `true` if successful.
    func authenticate(result: @escaping Handler<Bool>)
}

// MARK: - LocalAuthenticationManager
/// Manages local authentication using `LocalAuthentication` framework.
final public class LocalAuthenticationManager {
    private lazy var context = LAContext()
        .with { $0.localizedCancelTitle = "Cancelar" }
    private var error: NSError?
    public init() {}
}

// MARK: - LocalAuthenticationManagerProtocol
extension LocalAuthenticationManager: LocalAuthenticationManagerProtocol {
    private var canAuthenticateWithBiometrics: Bool { context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) }

    public var biometryType: LocalAuthenticationType.BiometryType? {
        switch context.biometryType {
        case .faceID: .faceId
        case .opticID: .opticId
        case .touchID: .touchId
        default: nil
        }
    }

    public var canAuthenticate: Bool { context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) }
    public var isBiometricAuthenticationSupported: Bool { context.biometryType != .none }

    public var localAuthenticationType: LocalAuthenticationType {
        guard canAuthenticateWithBiometrics else { return canAuthenticate ? .passcode : .none }
        return switch context.biometryType {
        case .faceID: .biometry(.faceId)
        case .opticID: .biometry(.opticId)
        case .touchID: .biometry(.touchId)
        default: canAuthenticate ? .passcode : .none
        }
    }

    public func authenticate(result: @escaping Handler<Bool>) {
        guard canAuthenticate else { dispatchOnMain { result(false) }; return }
        let reason = "Se requiere autenticación para proteger sus datos personales."
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            dispatchOnMain { result(error.isNil ? success : false) }
        }
    }
}
