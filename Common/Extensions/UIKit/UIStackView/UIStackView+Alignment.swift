//
//  UIStackView+Alignment.swift
//

import UIKit

extension UIStackView {
    
    /// Sets the alignment and returns self (chainable).
    /// - Parameter alignment: The alignment to set.
    @discardableResult public func alignment(_ alignment: Alignment) -> Self {
        with { $0.alignment = alignment }
    }
}
