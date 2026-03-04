//
//  AppleUser.swift
//

// MARK: - AppleUser
// MARK: - AppleUser
/// A structure representing an Apple ID user.
public struct AppleUser {
    
    /// The user identifier.
    public let id: String
    
    /// The user's given name.
    public let name: String?
    
    /// The user's last name.
    public let lastName: String?
    
    /// The user's email address.
    public let email: String?

    /// Initializes a new AppleUser from an `AppleUserModel`.
    public init(appleUserModel: AppleUserModel) {
        self.id = appleUserModel.id
        self.name = appleUserModel.name
        self.lastName = appleUserModel.lastName
        self.email = appleUserModel.email
    }
}

// MARK: - Storable
extension AppleUser: Storable {}
