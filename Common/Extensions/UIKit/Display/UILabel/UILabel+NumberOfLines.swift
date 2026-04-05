//
//  UILabel+NumberOfLines.swift
//

import UIKit

extension UILabel {
    
    /// Sets the number of lines and returns self (chainable).
    /// - Parameter numberOfLines: The maximum number of lines. Use 0 for unlimited. Defaults to 0.
    @discardableResult public func numberOfLines(_ numberOfLines: Int = .zero) -> Self {
        with { $0.numberOfLines = numberOfLines }
    }
}
