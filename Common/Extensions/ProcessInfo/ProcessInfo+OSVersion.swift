//
//  ProcessInfo+OSVersion.swift
//

import Foundation

extension ProcessInfo {
    var osVersion: String { "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)" }
}
