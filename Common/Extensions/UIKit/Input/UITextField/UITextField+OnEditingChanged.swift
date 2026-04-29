//
//  UITextField+OnEditingChanged.swift
//

import UIKit

private var uiTextFieldOnEditingChangedKey: UInt8 = 0

extension UITextField {
    private var onEditingChangedHandler: Handler<UITextField>? {
        get { objc_getAssociatedObject(self, &uiTextFieldOnEditingChangedKey) as? Handler<UITextField> }
        set { objc_setAssociatedObject(self, &uiTextFieldOnEditingChangedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for when editing changes and returns self (chainable).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingChanged(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingChangedHandler = handler
            $0.removeTarget($0, action: #selector(didEditingChanged), for: .editingChanged)
            $0.addTarget($0, action: #selector(didEditingChanged), for: .editingChanged)
        }
    }

    @objc private func didEditingChanged() {
        onEditingChangedHandler?(self)
    }
}
