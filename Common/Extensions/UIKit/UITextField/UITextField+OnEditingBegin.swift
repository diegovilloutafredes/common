//
//  UITextField+OnEditingBegin.swift
//

import UIKit

extension UITextField {
    private var onEditingDidBeginHandler: Handler<UITextField>? {
        get { associatedObject(for: "onEditingDidBeginHandler") as? Handler<UITextField> }
        set { set(associatedObject: newValue, for: "onEditingDidBeginHandler") }
    }

    /// Sets a handler for when editing begins and returns self (chainable).
    /// - Parameter handler: The handler to execute with the text field.
    @discardableResult public func onEditingDidBegin(_ handler: @escaping Handler<UITextField>) -> Self {
        with {
            $0.onEditingDidBeginHandler = handler
            addTarget($0, action: #selector(didEditingBegin), for: .editingDidBegin)
        }
    }

    @objc private func didEditingBegin() {
        onEditingDidBeginHandler?(self)
    }
}
