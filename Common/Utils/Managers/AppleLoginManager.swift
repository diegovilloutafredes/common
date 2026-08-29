//
//  AppleLoginManager.swift
//

import AuthenticationServices

/// The outcome of a successful Sign in with Apple flow: the credential plus the
/// decoded claims of its identity token.
public typealias AppleLoginCredentials = (appleIdCredential: ASAuthorizationAppleIDCredential, decodedIdentityToken: [String: Any])

// MARK: - AppleLoginError
/// Errors raised by ``AppleLoginManager`` itself. Errors from the system flow
/// (`ASAuthorizationError`, e.g. `.canceled` or `.unknown` when the app lacks the
/// Sign in with Apple entitlement) are passed through unchanged.
public enum AppleLoginError: LocalizedError, Equatable {
    /// The credential carried no identity token, or the token was not a valid JWT.
    case badToken
    /// The identity token's payload decoded, but was not a JSON object.
    case malformedPayload
    /// `performLogin` was called while a previous request was still pending.
    case alreadyInProgress

    public var errorDescription: String? {
        switch self {
        case .badToken: "The Apple identity token is missing or malformed."
        case .malformedPayload: "The Apple identity token payload is not a JSON object."
        case .alreadyInProgress: "A Sign in with Apple request is already in progress."
        }
    }
}

// MARK: - AppleLoginManagerProtocol
/// A protocol defining the interface for performing Apple Login.
public protocol AppleLoginManagerProtocol: AnyObject {

    /// Performs an Apple Login request.
    /// - Parameters:
    ///   - context: The view controller providing the presentation anchor. Held
    ///     weakly; its window is used when it has one, the key window otherwise.
    ///   - result: The completion handler returning the credentials or an error.
    ///     Delivered exactly once per accepted request; a request made while
    ///     another is pending fails immediately with ``AppleLoginError/alreadyInProgress``.
    func performLogin(from context: UIViewController, result: @escaping ResultHandler<AppleLoginCredentials>)
}

// MARK: - AppleLoginManager
/// A manager that handles Sign in with Apple authentication.
///
/// Keep the manager in a property: it is the authorization controller's
/// delegate and must outlive the flow.
public final class AppleLoginManager: NSObject {
    private var authController: ASAuthorizationController?
    private weak var context: UIViewController?
    private var result: ResultHandler<AppleLoginCredentials>?
}

// MARK: - AppleLoginManagerProtocol
extension AppleLoginManager: AppleLoginManagerProtocol {
    public func performLogin(from context: UIViewController, result: @escaping ResultHandler<AppleLoginCredentials>) {
        guard authController == nil else { result(.failure(AppleLoginError.alreadyInProgress)); return }
        self.context = context
        self.result = result

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        authController = controller
        controller.performRequests()
    }

    /// Hands the outcome to the pending handler and clears the request state so
    /// the next `performLogin` is accepted.
    private func deliver(_ outcome: Result<AppleLoginCredentials, Error>) {
        let handler = result
        result = nil
        authController = nil
        context = nil
        handler?(outcome)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityTokenAsData = appleIdCredential.identityToken,
            let identityToken = identityTokenAsData.asString()
        else { deliver(.failure(AppleLoginError.badToken)); return }
        do {
            deliver(.success((appleIdCredential, try Self.decode(jwtToken: identityToken))))
        } catch {
            deliver(.failure(error))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.log(["error": error])
        deliver(.failure(error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        context?.view.window ?? UIApplication.shared.keyWindow ?? ASPresentationAnchor()
    }
}

// MARK: - JWT decoding
extension AppleLoginManager {

    /// Decodes the payload (second segment) of a JWT. Internal for tests.
    static func decode(jwtToken: String) throws -> [String: Any] {
        let segments = jwtToken.components(separatedBy: ".")
        guard segments.count >= 3 else { throw AppleLoginError.badToken }
        return try decodeJWTPart(segments[1])
    }

    private static func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        guard
            let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
            let payload = json as? [String: Any]
        else { throw AppleLoginError.malformedPayload }
        return payload
    }

    /// base64url → base64 (restoring the stripped padding).
    private static func base64Decode(_ base64url: String) throws -> Data {
        let base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else { throw AppleLoginError.badToken }
        return decoded
    }
}
