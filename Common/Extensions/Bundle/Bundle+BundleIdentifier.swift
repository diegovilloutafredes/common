//
//  Bundle+BundleIdentifier.swift
//

// MARK: - Bundle Identifier
extension Bundle {
    
    /// Returns the bundle identifier (CFBundleIdentifier).
    // Disfavored: Foundation declares it with the same type and value, and a file importing both modules was ambiguous.
    @_disfavoredOverload
    public var bundleIdentifier: String? { infoDictionary?["CFBundleIdentifier"] as? String }
}
