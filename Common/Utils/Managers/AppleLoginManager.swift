//
//  AppleLoginManager.swift
//

import AuthenticationServices

// MARK: - AppleLoginManagerProtocol
public protocol AppleLoginManagerProtocol: AnyObject {
    func performLogin(from context: AnyObject, result: @escaping ResultHandler<(appleIdCredential: ASAuthorizationAppleIDCredential, decodedIdentityToken: [String: Any])>)
}

// MARK: - AppleLoginManager
final public class AppleLoginManager: NSObject {
    private var authController: ASAuthorizationController!
    private var context: AnyObject!
    private var result: ResultHandler<(appleIdCredential: ASAuthorizationAppleIDCredential, decodedIdentityToken: [String: Any])>!
}

// MARK: - AppleLoginManagerProtocol
extension AppleLoginManager: AppleLoginManagerProtocol {
    public func performLogin(from context: AnyObject, result: @escaping ResultHandler<(appleIdCredential: ASAuthorizationAppleIDCredential, decodedIdentityToken: [String: Any])>) {
        self.context = context
        self.result = result

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        request.requestedScopes = [.fullName, .email]

        authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityTokenAsData = appleIdCredential.identityToken,
            let identityToken = identityTokenAsData.asString(),
            let decodedIdentityToken = try? decode(jwtToken: identityToken)
        else { return }
        let data = (appleIdCredential, decodedIdentityToken)
        Logger.log(["data": data])
        result(.success(data))
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.log(["error": error])
        result(.failure(error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor { (context as! UIViewController).view.window! }
}

// MARK: - Convenience
extension AppleLoginManager {
    private func decode(jwtToken: String) throws -> [String: Any] {
        func base64Decode(_ base64: String) throws -> Data {
            let base64 = base64
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else { throw DecodeErrors.badToken }
            return decoded
        }

        func decodeJWTPart(_ value: String) throws -> [String: Any] {
            let bodyData = try base64Decode(value)
            let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
            guard let payload = json as? [String: Any] else { throw DecodeErrors.other }
            return payload
        }

        let segments = jwtToken.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
}

// MARK: - DecodeErrors
private enum DecodeErrors: Error {
    case badToken
    case other
}

// MARK: - AppleUserInfoModel
extension ASAuthorizationAppleIDCredential: AppleUserInfoModel {
    var id: String { user }
    var name: String? { fullName?.givenName }
    var lastName: String? { fullName?.familyName }
}

// MARK: - AppleUserInfo
struct AppleUserInfo {
    let id: String
    var name: String?
    var lastName: String?
    var email: String?

    init(model: AppleUserInfoModel) {
        id = model.id
        name = model.name
        lastName = model.lastName
        email = model.email
    }
}

// MARK: - Storable
extension AppleUserInfo: Storable {}


// MARK: - AppleUserInfoModel
protocol AppleUserInfoModel: AnyObject {
    var id: String { get }
    var name: String? { get }
    var lastName: String? { get }
    var email: String? { get }
}
