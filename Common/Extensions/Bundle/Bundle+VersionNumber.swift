//
//  Bundle+VersionNumber.swift
//

// MARK: - Version Number
extension Bundle {
    public var versionNumber: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? .zero }
}
