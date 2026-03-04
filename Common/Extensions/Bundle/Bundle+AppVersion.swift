//
//  Bundle+AppVersion.swift
//

// MARK: - App Version
// MARK: - App Version
extension Bundle {
    
    /// Returns the app version in the format "Version.Build".
    public var appVersion: String { "\(versionNumber).\(buildNumber)" }
}
