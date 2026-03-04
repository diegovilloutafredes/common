//
//  AppleUserConvertible.swift
//

// MARK: - AppleUserConvertible
// MARK: - AppleUserConvertible
/// A type that can be converted into an `AppleUser`.
public protocol AppleUserConvertible {
    
    /// Returns an `AppleUser` representation.
    var asAppleUser: AppleUser { get }
}

// MARK: - Default implementation where Self: AppleUserModel
extension AppleUserConvertible where Self: AppleUserModel {
    public var asAppleUser: AppleUser { .init(appleUserModel: self) }
}
