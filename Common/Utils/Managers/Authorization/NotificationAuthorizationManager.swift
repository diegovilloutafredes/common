//
//  NotificationAuthorizationManager.swift
//

import UIKit

// MARK: - NotificationAuthorizationManager
// MARK: - NotificationAuthorizationManager
/// Manges the authorization request for push notifications.
public enum NotificationAuthorizationManager {
    
    /// Retrieves the current notification authorization status.
    /// - Parameter handler: Completion handler with the status.
    public static func getCurrentStatus(handler: @escaping Handler<AuthorizationStatus>) {
        UNUserNotificationCenter.current().getNotificationSettings {
            let authorizationStatus = $0.authorizationStatus.asAuthorizationStatus
            dispatchOnMain { handler(authorizationStatus) }
        }
    }

    /// Requests authorization for push notifications.
    /// - Parameter handler: Completion handler with success status.
    public static func requestAuthorization(handler: @escaping Handler<Bool>) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, _ in
            status ? NotificationRegisterManager.registerForRemoteNotifications() : NotificationRegisterManager.unregisterForRemoteNotifications()
            dispatchOnMain { handler(status) }
        }
    }
}
