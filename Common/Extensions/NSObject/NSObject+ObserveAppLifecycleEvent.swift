//
//  NSObject+ObserveAppLifecycleEvent.swift
//

import UIKit

extension NSObject {

    // MARK: - AppLifecycleEvent
    
    /// Enumeration representing application lifecycle events.
    public enum AppLifecycleEvent {
        case onDidBecomeActive
        case onDidEnterBackground
        case onWillEnterForeground
        case onWillResignActive
        case onWillTerminate

        var asNotificationName: Notification.Name {
            switch self {
            case .onDidBecomeActive: UIApplication.didBecomeActiveNotification
            case .onDidEnterBackground: UIApplication.didEnterBackgroundNotification
            case .onWillEnterForeground: UIApplication.willEnterForegroundNotification
            case .onWillResignActive: UIApplication.willResignActiveNotification
            case .onWillTerminate: UIApplication.willTerminateNotification
            }
        }
    }

    /// Observes a lifecycle event and performs an action when it occurs.
    /// - Parameters:
    ///   - event: The lifecycle event to observe.
    ///   - action: The action to perform.
    /// - Returns: Self (chainable).
    @discardableResult public func observe(_ event: AppLifecycleEvent, action: @escaping Action) -> Self {
        observe(event.asNotificationName, action: action)
    }

    /// Stops observing a lifecycle event.
    /// - Parameter event: The lifecycle event to stop observing.
    /// - Returns: Self (chainable).
    @discardableResult public func removeObserver(_ event: AppLifecycleEvent) -> Self {
        removeObserver(event.asNotificationName)
    }
}
