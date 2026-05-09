//
//  NotificationAuthorizationManager.swift
//

import UIKit

// MARK: - NotificationAuthorizationManager
/// Manages the authorization request for push notifications.
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
    /// - Parameters:
    ///   - options: The notification types to request. Defaults to `[.alert, .badge, .sound]`.
    ///   - handler: Completion handler with success status. Call `NotificationRegisterManager.registerForRemoteNotifications()` if remote push is needed.
    public static func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound], handler: @escaping Handler<Bool>) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { status, _ in
            dispatchOnMain { handler(status) }
        }
    }
}
