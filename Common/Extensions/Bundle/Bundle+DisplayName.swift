//
//  Bundle+DisplayName.swift
//

// MARK: - Display Name
// MARK: - Display Name
extension Bundle {
    
    /// Returns the display name (CFBundleDisplayName) of the bundle.
    public var displayName: String { infoDictionary?["CFBundleDisplayName"] as? String ?? .empty }
}
