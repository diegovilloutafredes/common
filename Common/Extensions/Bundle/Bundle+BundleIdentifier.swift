//
//  Bundle+BundleIdentifier.swift
//

// MARK: - Bundle Identifier
extension Bundle {
    public var bundleIdentifier: String? { infoDictionary?["CFBundleIdentifier"] as? String }
}
