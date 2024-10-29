//
//  Bundle+DisplayName.swift
//

// MARK: - Display Name
extension Bundle {
    public var displayName: String { infoDictionary?["CFBundleDisplayName"] as? String ?? .empty }
}
