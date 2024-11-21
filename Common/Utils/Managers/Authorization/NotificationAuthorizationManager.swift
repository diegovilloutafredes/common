//
//  NotificationAuthorizationManager.swift
//

import UIKit

// MARK: - NotificationAuthorizationManager
public enum NotificationAuthorizationManager {
    public static func getCurrentStatus(handler: @escaping Handler<AuthorizationStatus>) {
        UNUserNotificationCenter.current().getNotificationSettings {
            let authorizationStatus = $0.authorizationStatus.asAuthorizationStatus
            if authorizationStatus == .authorized { NotificationRegisterManager.registerForRemoteNotifications() }
            dispatchOnMain { handler(authorizationStatus) }
        }
    }

    public static func requestAuthorization(handler: @escaping Handler<Bool>) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, _ in
            if status { NotificationRegisterManager.registerForRemoteNotifications() }
            dispatchOnMain { handler(status) }
        }
    }
}
