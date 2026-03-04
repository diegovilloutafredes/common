//
//  UITextField+OnEditingChanged.swift
//

import UIKit

extension UITextField {
    private var onEditingChangedHandler: Handler<UITextField>? {
        get { associatedObject(for: "onEditingChangedHandler") as? Handler<UITextField> }
        set { set(associatedObject: newValue, for: "onEditingChangedHandler") }
    }

    /// Sets a handler for when editing changes and returns self (chainable).
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingChanged(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingChangedHandler = handler
            addTarget($0, action: #selector(didEditingChanged), for: .editingChanged)
        }
    }

    @objc private func didEditingChanged() {
        onEditingChangedHandler?(self)
    }
}
