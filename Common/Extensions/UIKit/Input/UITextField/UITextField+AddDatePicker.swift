//
//  UITextField+AddDatePicker.swift
//

import UIKit

extension UITextField {
    
    /// Adds a date picker as the input view and returns self (chainable).
    /// - Parameters:
    ///   - dateFormatAsString: The date format string. Defaults to dd/MM/yyyy.
    ///   - datePickerHandler: A closure to configure the date picker.
    @discardableResult public func addDatePicker(dateFormatAsString: String = .DateFormats.ddDEMMMMDELyyyy, datePickerHandler: InOutHandler<UIDatePicker> = { $0 } ) -> Self {
        with { textField in
            textField
                .inputView(
                    datePickerHandler(.init())
                        .datePickerMode(.date)
                        .onValueChanged { textField.text($0.toString(with: dateFormatAsString)) }
                        .preferredDatePickerStyle(.wheels)
                )
        }
    }
}
