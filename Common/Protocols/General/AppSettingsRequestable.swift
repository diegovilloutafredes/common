//
//  AppSettingsRequestable.swift
//

import UIKit

// MARK: - AppSettingsRequestable
// MARK: - AppSettingsRequestable
/// A protocol for objects that can request to open the app's settings in the System Settings app.
public protocol AppSettingsRequestable: AnyObject {
    
    /// Requests to open the app settings.
    func onAppSettingsRequested()
}

// MARK: - Default implementation
extension AppSettingsRequestable {
    public func onAppSettingsRequested() { UIApplication.openAppSettings() }
}
