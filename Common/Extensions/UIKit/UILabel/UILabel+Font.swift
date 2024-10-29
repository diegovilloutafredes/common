//
//  UILabel+Font.swift
//

import UIKit

extension UILabel {
    @discardableResult public func font(_ font: UIFont = .systemFont(ofSize: 14)) -> Self {
        with { $0.font = font }
    }
}
