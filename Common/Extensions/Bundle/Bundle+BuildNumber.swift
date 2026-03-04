//
//  Bundle+BuildNumber.swift
//

// MARK: - Build Number
// MARK: - Build Number
extension Bundle {
    
    /// Returns the build number (CFBundleVersion) of the bundle.
    public var buildNumber: String { infoDictionary?["CFBundleVersion"] as? String ?? .zero }
}
