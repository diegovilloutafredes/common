//
//  NSObject+ObserveAppLifecycleEvent.swift
//

import UIKit

extension NSObject {

    // MARK: - AppLifecycleEvent
    public enum AppLifecycleEvent {
        case onDidBecomeActive
        case onDidEnterBackground
        case onWillEnterForeground
        case onWillResignActive

        var asNotificationName: Notification.Name {
            switch self {
            case .onDidBecomeActive: UIApplication.didBecomeActiveNotification
            case .onDidEnterBackground: UIApplication.didEnterBackgroundNotification
            case .onWillEnterForeground: UIApplication.willEnterForegroundNotification
            case .onWillResignActive: UIApplication.willResignActiveNotification
            }
        }
    }

    private var onEventHandler: Action? {
        get { associatedObject(for: "onEventHandler") as? Action }
        set { set(associatedObject: newValue, for: "onEventHandler") }
    }

    @objc private func onEvent() { onEventHandler?() }

    @discardableResult public func observe(_ event: AppLifecycleEvent, action: @escaping Action) -> Self {
        observe(event.asNotificationName, action: action)
    }

    @discardableResult public func removeObserver(_ event: AppLifecycleEvent) -> Self {
        removeObserver(event.asNotificationName)
    }

    @discardableResult public func observe(_ name: Notification.Name, action: @escaping Action) -> Self {
        with {
            $0.onEventHandler = action
            NotificationCenter
                .default
                .addObserver(
                    $0,
                    selector: #selector(onEvent),
                    name: name,
                    object: nil
                )
        }
    }

    @discardableResult public func post(_ name: Notification.Name) -> Self {
        with { _ in
            NotificationCenter
                .default
                .post(
                    name: name,
                    object: nil
                )
        }
    }

    @discardableResult public func removeObserver(_ name: Notification.Name) -> Self {
        with {
            $0.onEventHandler = nil
            NotificationCenter
                .default
                .removeObserver(
                    $0,
                    name: name,
                    object: nil
                )
        }
    }
}
