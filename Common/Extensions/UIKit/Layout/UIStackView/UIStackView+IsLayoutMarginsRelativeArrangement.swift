//
//  UIStackView+IsLayoutMarginsRelativeArrangement.swift
//

import UIKit

extension UIStackView {
    
    /// Sets whether the layout is relative to layout margins and returns self (chainable).
    /// - Parameter isLayoutMarginsRelativeArrangement: `true` to use layout margins.
    @discardableResult public func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement: Bool) -> Self {
        with { $0.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement }
    }
}
