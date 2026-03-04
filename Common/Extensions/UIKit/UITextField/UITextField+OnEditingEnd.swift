//
//  UITextField+OnEditingEnd.swift
//

import UIKit

extension UITextField {
    private var onEditingDidEndHandler: Handler<UITextField>? {
        get { associatedObject(for: "onEditingDidEndHandler") as? Handler<UITextField> }
        set { set(associatedObject: newValue, for: "onEditingDidEndHandler") }
    }

    /// Sets a handler for when editing ends and returns self (chainable).
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingDidEnd(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingDidEndHandler = handler
            addTarget($0, action: #selector(didEditingEnd), for: .editingDidEnd)
        }
    }

    @objc private func didEditingEnd() {
        onEditingDidEndHandler?(self)
    }
}
