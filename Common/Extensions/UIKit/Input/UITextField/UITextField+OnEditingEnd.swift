//
//  UITextField+OnEditingEnd.swift
//

import UIKit

nonisolated(unsafe) private var uiTextFieldOnEditingDidEndKey: UInt8 = 0

extension UITextField {
    private var onEditingDidEndHandler: Handler<UITextField>? {
        get { objc_getAssociatedObject(self, &uiTextFieldOnEditingDidEndKey) as? Handler<UITextField> }
        set { objc_setAssociatedObject(self, &uiTextFieldOnEditingDidEndKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for when editing ends and returns self (chainable).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingDidEnd(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingDidEndHandler = handler
            $0.removeTarget($0, action: #selector(didEditingEnd), for: .editingDidEnd)
            $0.addTarget($0, action: #selector(didEditingEnd), for: .editingDidEnd)
        }
    }

    @objc private func didEditingEnd() {
        onEditingDidEndHandler?(self)
    }
}
