//
//  UIDatePicker+.swift
//

import UIKit

extension UIDatePicker {
    private var onValueChangedHandler: Handler<Date>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<Date> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    @discardableResult public func onValueChanged(_ handler: @escaping Handler<Date>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            addTarget($0, action: #selector(valueChanged(sender:)), for: .valueChanged)
        }
    }

    @objc private func valueChanged(sender: UIDatePicker) {
        onValueChangedHandler?(sender.date)
    }
}

extension UIDatePicker {
    @discardableResult public func datePickerMode(_ datePickerMode: Mode) -> Self {
        with { $0.datePickerMode = datePickerMode }
    }
}

extension UIDatePicker {
    @discardableResult public func locale(_ locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Self {
        with { $0.locale = locale }
    }

    @discardableResult public func locale(_ locale: String = .DefaultValues.Locale.esCL) -> Self {
        with { $0.locale (.init(identifier: locale)) }
    }
}

extension UIDatePicker {
    @discardableResult public func maximumDate(_ maximumDate: Date? = .now) -> Self {
        with { $0.maximumDate = maximumDate }
    }
}

extension UIDatePicker {
    @discardableResult public func preferredDatePickerStyle(_ preferredDatePickerStyle: UIDatePickerStyle) -> Self {
        with { $0.preferredDatePickerStyle = preferredDatePickerStyle }
    }
}
