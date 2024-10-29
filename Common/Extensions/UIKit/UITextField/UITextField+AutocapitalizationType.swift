//
//  UITextField+AutocapitalizationType.swift
//

import UIKit

extension UITextField {
    @discardableResult public func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        with { $0.autocapitalizationType = autocapitalizationType }
    }
}
