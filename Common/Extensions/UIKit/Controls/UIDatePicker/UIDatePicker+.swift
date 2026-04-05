//
//  UIDatePicker+.swift
//

import UIKit

extension UIDatePicker {
    private var onValueChangedHandler: Handler<Date>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<Date> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }
}

extension UIDatePicker {
    
    /// Sets a handler for value changed events.
    /// - Parameter handler: The closure to execute when the date changes.
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
    
    /// Sets the date picker mode and returns self (chainable).
    /// - Parameter datePickerMode: The date picker mode.
    @discardableResult public func datePickerMode(_ datePickerMode: Mode) -> Self {
        with { $0.datePickerMode = datePickerMode }
    }
}

extension UIDatePicker {
    
    /// Sets the locale and returns self (chainable).
    /// - Parameter locale: The locale to set. Defaults to Chilean locale.
    @discardableResult public func locale(_ locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Self {
        with { $0.locale = locale }
    }

    /// Sets the locale by identifier and returns self (chainable).
    /// - Parameter locale: The locale identifier string. Defaults to Chilean locale.
    @discardableResult public func locale(_ locale: String = .DefaultValues.Locale.esCL) -> Self {
        with { $0.locale (.init(identifier: locale)) }
    }
}

extension UIDatePicker {
    
    /// Sets the maximum date and returns self (chainable).
    /// - Parameter maximumDate: The maximum allowed date. Defaults to `.now`.
    @discardableResult public func maximumDate(_ maximumDate: Date? = .now) -> Self {
        with { $0.maximumDate = maximumDate }
    }
}

extension UIDatePicker {
    
    /// Sets the preferred date picker style and returns self (chainable).
    /// - Parameter preferredDatePickerStyle: The style to set.
    @discardableResult public func preferredDatePickerStyle(_ preferredDatePickerStyle: UIDatePickerStyle) -> Self {
        with { $0.preferredDatePickerStyle = preferredDatePickerStyle }
    }
}
