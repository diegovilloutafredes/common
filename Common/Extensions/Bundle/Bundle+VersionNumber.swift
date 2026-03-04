//
//  Bundle+VersionNumber.swift
//

// MARK: - Version Number
// MARK: - Version Number
extension Bundle {
    
    /// Returns the short version string (CFBundleShortVersionString) of the bundle.
    public var versionNumber: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? .zero }
}
