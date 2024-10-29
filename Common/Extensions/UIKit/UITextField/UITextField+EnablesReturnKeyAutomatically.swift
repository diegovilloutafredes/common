//
//  UITextField+EnablesReturnKeyAutomatically.swift
//

import UIKit

extension UITextField {
    @discardableResult public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        with { $0.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically }
    }
}
