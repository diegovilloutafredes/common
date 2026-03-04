//
//  UIApplication+AppSettings.swift
//

import UIKit

extension UIApplication {
    
    /// Opens the application settings in the Settings app.
    public static func openAppSettings() {
        guard
            let appSettingsUrl = URL(string: openSettingsURLString),
            shared.canOpenURL(appSettingsUrl)
        else { return }
        shared.open(appSettingsUrl)
    }
}
