//
//  UITextField+OnEditingChanged.swift
//

import UIKit

extension UITextField {
    private var onEditingChangedHandler: Handler<UITextField>? {
        get { associatedObject(for: "onEditingChangedHandler") as? Handler<UITextField> }
        set { set(associatedObject: newValue, for: "onEditingChangedHandler") }
    }

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
