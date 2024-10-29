//
//  Bundle+BuildNumber.swift
//

// MARK: - Build Number
extension Bundle {
    public var buildNumber: String { infoDictionary?["CFBundleVersion"] as? String ?? .zero }
}
