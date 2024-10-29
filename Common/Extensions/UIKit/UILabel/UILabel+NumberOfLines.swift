//
//  UILabel+NumberOfLines.swift
//

import UIKit

extension UILabel {
    @discardableResult public func numberOfLines(_ numberOfLines: Int = .zero) -> Self {
        with { $0.numberOfLines = numberOfLines }
    }
}
