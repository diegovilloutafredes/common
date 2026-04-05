//
//  UIRefreshControl+OnValueChanged.swift
//

import UIKit

extension UIRefreshControl {
    private var onValueChangedHandler: Action? {
        get { associatedObject(for: "onValueChangedHandler") as? Action }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    /// Sets a handler for value changed events (triggered on pull-to-refresh).
    /// - Parameter handler: The closure to execute when refreshing.
    @discardableResult public func onValueChanged(_ handler: @escaping Action) -> Self {
        with {
            $0.onValueChangedHandler = handler
            addTarget($0, action: #selector(valueChanged), for: .valueChanged)
        }
    }

    @objc private func valueChanged() {
        onValueChangedHandler?()
    }
}
