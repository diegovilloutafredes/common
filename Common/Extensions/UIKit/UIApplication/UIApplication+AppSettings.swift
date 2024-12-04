//
//  UIApplication+AppSettings.swift
//

import UIKit

extension UIApplication {
    public static func openAppSettings() {
        guard
            let appSettingsUrl = URL(string: openSettingsURLString),
            shared.canOpenURL(appSettingsUrl)
        else { return }
        shared.open(appSettingsUrl)
    }
}
