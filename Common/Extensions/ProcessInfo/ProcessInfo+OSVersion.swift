//
//  ProcessInfo+OSVersion.swift
//

import Foundation

extension ProcessInfo {
    public var osVersion: String { "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)" }
}
