//
//  UISwitch+OnValueChanged.swift
//

import UIKit

extension UISwitch {
    private var onValueChangedHandler: Handler<Bool>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<Bool> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    @discardableResult public func onValueChanged(_ handler: @escaping Handler<Bool>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            addTarget($0, action: #selector(valueChanged(sender:)), for: .valueChanged)
        }
    }

    @objc private func valueChanged(sender: UISwitch) {
        onValueChangedHandler?(sender.isOn)
    }
}
