//
//  Bundle+TargetName.swift
//

import Foundation

// MARK: - Target Name
extension Bundle {
    public var targetName: String { infoDictionary?["CFBundleName"] as? String ?? .empty }
}
