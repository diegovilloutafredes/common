//
//  Bundle+BundleIdentifier.swift
//

// MARK: - Bundle Identifier
// MARK: - Bundle Identifier
extension Bundle {
    
    /// Returns the bundle identifier (CFBundleIdentifier).
    public var bundleIdentifier: String? { infoDictionary?["CFBundleIdentifier"] as? String }
}
