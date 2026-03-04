//
//  ProcessInfo+OSVersion.swift
//

import Foundation

extension ProcessInfo {
    
    /// Returns the operating system version as a string (major.minor.patch).
    public var osVersion: String { "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)" }
}
