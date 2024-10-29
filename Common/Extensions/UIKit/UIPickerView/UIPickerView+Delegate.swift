//
//  UIPickerView+Delegate.swift
//

import UIKit

extension UIPickerView {
    @discardableResult public func delegate(_ delegate: UIPickerViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
