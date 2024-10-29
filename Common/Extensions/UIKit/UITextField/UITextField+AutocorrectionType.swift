//
//  UITextField+AutocorrectionType.swift
//

import UIKit

extension UITextField {
    @discardableResult public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        with { $0.autocorrectionType = autocorrectionType }
    }
}
