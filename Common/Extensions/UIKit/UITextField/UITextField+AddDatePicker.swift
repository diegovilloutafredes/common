//
//  UITextField+AddDatePicker.swift
//

import UIKit

extension UITextField {
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
