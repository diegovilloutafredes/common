//
//  NotificationRegisterManager.swift
//

import UIKit

// MARK: - NotificationRegisterManager
// MARK: - NotificationRegisterManager
/// A manager that handles registration and unregistration for remote notifications.
public enum NotificationRegisterManager {
    
    /// Registers the app for remote notifications on the main thread.
    public static func registerForRemoteNotifications() {
        dispatchOnMain { UIApplication.shared.registerForRemoteNotifications() }
    }

    /// Unregisters the app for remote notifications on the main thread.
    public static func unregisterForRemoteNotifications() {
        dispatchOnMain { UIApplication.shared.unregisterForRemoteNotifications() }
    }
}
