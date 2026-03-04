//
//  ASAuthorizationAppleIDCredential.swift
//

import AuthenticationServices

// MARK: - AppleUserModel
// MARK: - AppleUserModel
/// Conformance of `ASAuthorizationAppleIDCredential` to `AppleUserModel`, mapping properties to Apple ID credentials.
extension ASAuthorizationAppleIDCredential: AppleUserModel {
    
    /// The user identifier.
    public var id: String { user }
    
    /// The given name of the user.
    public var name: String? { fullName?.givenName }
    
    /// The family name (last name) of the user.
    public var lastName: String? { fullName?.familyName }
}
