//
//  UILabel+Text.swift
//

import UIKit

extension UILabel {
    @discardableResult public func text(_ text: String?) -> Self {
        with { $0.text = text }
    }
}
