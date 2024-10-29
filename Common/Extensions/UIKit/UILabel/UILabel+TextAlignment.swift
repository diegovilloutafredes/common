//
//  UILabel+TextAlignment.swift
//

import UIKit

extension UILabel {
    @discardableResult public func textAlignment(_ textAlignment: NSTextAlignment? = .left) -> Self {
        with { $0.textAlignment = textAlignment! }
    }
}
