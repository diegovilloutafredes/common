//
//  UITextField+OnEditingBegin.swift
//

import UIKit

nonisolated(unsafe) private var uiTextFieldOnEditingDidBeginKey: UInt8 = 0

extension UITextField {
    private var onEditingDidBeginHandler: Handler<UITextField>? {
        get { objc_getAssociatedObject(self, &uiTextFieldOnEditingDidBeginKey) as? Handler<UITextField> }
        set { objc_setAssociatedObject(self, &uiTextFieldOnEditingDidBeginKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for when editing begins and returns self (chainable).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingDidBegin(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingDidBeginHandler = handler
            $0.removeTarget($0, action: #selector(didEditingBegin), for: .editingDidBegin)
            $0.addTarget($0, action: #selector(didEditingBegin), for: .editingDidBegin)
        }
    }

    @objc private func didEditingBegin() {
        onEditingDidBeginHandler?(self)
    }
}
