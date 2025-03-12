//
//  Bundle+TargetName.swift
//

// MARK: - Target Name
extension Bundle {
    public var targetName: String { infoDictionary?["CFBundleName"] as? String ?? .empty }
}
