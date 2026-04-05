//
//  UISwitch+OnValueChanged.swift
//

import UIKit

extension UISwitch {
    private var onValueChangedHandler: Handler<UISwitch>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<UISwitch> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    /// Sets a handler for value changed events and returns self (chainable).
    /// - Parameter handler: The closure to execute with the switch.
    @discardableResult public func onValueChanged(_ handler: @escaping Handler<UISwitch>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            addTarget($0, action: #selector(valueChanged), for: .valueChanged)
        }
    }

    @objc private func valueChanged() {
        onValueChangedHandler?(self)
    }
}
