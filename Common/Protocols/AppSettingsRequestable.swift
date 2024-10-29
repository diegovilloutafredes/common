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
    public func onAppSettingsRequested() {
        let application = UIApplication.shared
        let urlAsString = UIApplication.openSettingsURLString

        guard
            let url = URL(string: urlAsString),
            application.canOpenURL(url)
        else { return }

        application.open(url, options: [:])
    }
}
