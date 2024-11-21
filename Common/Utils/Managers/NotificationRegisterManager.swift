//
//  NotificationRegisterManager.swift
//

import UIKit

// MARK: - NotificationRegisterManager
public enum NotificationRegisterManager {
    public static func registerForRemoteNotifications() {
        dispatchOnMain { UIApplication.shared.registerForRemoteNotifications() }
    }

    public static func unregisterForRemoteNotifications() {
        dispatchOnMain { UIApplication.shared.unregisterForRemoteNotifications() }
    }
}
