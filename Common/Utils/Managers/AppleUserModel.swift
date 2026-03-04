//
//  AppleUserModel.swift
//

// MARK: - AppleUserModel
// MARK: - AppleUserModel
/// Defines the properties of an Apple ID user.
public protocol AppleUserModel {
    
    /// The user identifier.
    var id: String { get }
    
    /// The user's given name.
    var name: String? { get }
    
    /// The user's last name.
    var lastName: String? { get }
    
    /// The user's email address.
    var email: String? { get }
}
