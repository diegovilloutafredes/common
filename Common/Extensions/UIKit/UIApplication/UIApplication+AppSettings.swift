//
//  UIApplication+AppSettings.swift
//

import UIKit

extension UIApplication {
    public static func openAppSettings() {
        guard
            let appSettingsUrl = URL(string: openSettingsURLString),
            UIApplication.shared.canOpenURL(appSettingsUrl)
        else { return }
        UIApplication.shared.open(appSettingsUrl)
    }
}
