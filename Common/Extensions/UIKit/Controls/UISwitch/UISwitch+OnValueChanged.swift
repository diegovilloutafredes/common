//
//  UISwitch+OnValueChanged.swift
//

import UIKit

nonisolated(unsafe) private var uiSwitchOnValueChangedKey: UInt8 = 0

extension UISwitch {
    private var onValueChangedHandler: Handler<UISwitch>? {
        get { objc_getAssociatedObject(self, &uiSwitchOnValueChangedKey) as? Handler<UISwitch> }
        set { objc_setAssociatedObject(self, &uiSwitchOnValueChangedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for value changed events and returns self (chainable).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The closure to execute with the switch.
    @discardableResult public func onValueChanged(_ handler: @escaping Handler<UISwitch>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            $0.removeTarget($0, action: #selector(valueChanged), for: .valueChanged)
            $0.addTarget($0, action: #selector(valueChanged), for: .valueChanged)
        }
    }

    @objc private func valueChanged() {
        onValueChangedHandler?(self)
    }
}
