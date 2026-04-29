//
//  UIRefreshControl+OnValueChanged.swift
//

import UIKit

private var uiRefreshControlOnValueChangedKey: UInt8 = 0

extension UIRefreshControl {
    private var onValueChangedHandler: Action? {
        get { objc_getAssociatedObject(self, &uiRefreshControlOnValueChangedKey) as? Action }
        set { objc_setAssociatedObject(self, &uiRefreshControlOnValueChangedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for value changed events (triggered on pull-to-refresh).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The closure to execute when refreshing.
    @discardableResult public func onValueChanged(_ handler: @escaping Action) -> Self {
        with {
            $0.onValueChangedHandler = handler
            $0.removeTarget($0, action: #selector(valueChanged), for: .valueChanged)
            $0.addTarget($0, action: #selector(valueChanged), for: .valueChanged)
        }
    }

    @objc private func valueChanged() {
        onValueChangedHandler?()
    }
}
