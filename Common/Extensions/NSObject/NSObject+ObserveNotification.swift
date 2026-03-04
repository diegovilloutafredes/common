//
//  NSObject+ObserveNotification.swift
//

import UIKit

// MARK: - Observe Notification
extension NSObject {
    private var handlers: [Notification.Name: Action] {
        get { associatedObject(for: "handlers") as? [Notification.Name: Action] ?? [:] }
        set { set(associatedObject: newValue, for: "handlers") }
    }

    @objc private func onEvent(_ notification: Notification) {
        handlers[notification.name]?()
    }

    /// Observes a notification and performs an action when it is posted.
    /// - Parameters:
    ///   - name: The name of the notification.
    ///   - action: The action to perform.
    /// - Returns: Self (chainable).
    @discardableResult public func observe(_ name: Notification.Name, action: @escaping Action) -> Self {
        with {
            var handlers = $0.handlers
            handlers[name] = action
            $0.handlers = handlers

            NotificationCenter
                .default
                .addObserver(
                    $0,
                    selector: #selector(onEvent(_:)),
                    name: name,
                    object: nil
                )
        }
    }

    /// Posts a notification.
    /// - Parameter name: The name of the notification to post.
    /// - Returns: Self (chainable).
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

    /// Stops observing a notification.
    /// - Parameter name: The name of the notification.
    /// - Returns: Self (chainable).
    @discardableResult public func removeObserver(_ name: Notification.Name) -> Self {
        with {
            var handlers = $0.handlers
            handlers[name] = nil
            $0.handlers = handlers

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
