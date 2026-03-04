//
//  Bundle+TargetName.swift
//

// MARK: - Target Name
// MARK: - Target Name
extension Bundle {
    
    /// Returns the target name (CFBundleName) of the bundle.
    public var targetName: String { infoDictionary?["CFBundleName"] as? String ?? .empty }
}
