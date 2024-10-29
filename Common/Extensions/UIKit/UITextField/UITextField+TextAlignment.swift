//
//  UITextField+TextAlignment.swift
//

import UIKit

extension UITextField {
    @discardableResult public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        with { $0.textAlignment = textAlignment }
    }
}
