//
//  UILabel+AttributedText.swift
//

import UIKit

extension UILabel {
    @discardableResult public func attributedText(_ attributedText: NSAttributedString?) -> Self {
        with { $0.attributedText = attributedText }
    }
}
