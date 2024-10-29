//
//  Bundle+AppVersion.swift
//

// MARK: - App Version
extension Bundle {
    public var appVersion: String { "\(versionNumber).\(buildNumber)" }
}
