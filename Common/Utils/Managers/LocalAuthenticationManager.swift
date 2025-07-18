//
//  LocalAuthenticationManager.swift
//

import LocalAuthentication

// MARK: - LocalAuthenticationType
public enum LocalAuthenticationType: Stringable {
    case biometry(BiometryType)
    case none
    case passcode

    public enum BiometryType: Stringable {
        case faceId
        case opticId
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
public protocol LocalAuthenticationManagerProtocol: AnyObject {
    var biometryType: LocalAuthenticationType.BiometryType? { get }
    var canAuthenticate: Bool { get }
    var isBiometricAuthenticationSupported: Bool { get }
    var localAuthenticationType: LocalAuthenticationType { get }
    func authenticate(result: @escaping Handler<Bool>)
}

// MARK: - LocalAuthenticationManager
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
