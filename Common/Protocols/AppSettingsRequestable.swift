//
//  AppSettingsRequestable.swift
//

import UIKit

// MARK: - AppSettingsRequestable
public protocol AppSettingsRequestable: AnyObject {
    func onAppSettingsRequested()
}

// MARK: - Default implementation
extension AppSettingsRequestable {
    public func onAppSettingsRequested() { UIApplication.openAppSettings() }
}
