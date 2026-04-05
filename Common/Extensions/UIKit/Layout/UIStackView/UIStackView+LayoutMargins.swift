//
//  UIStackView+LayoutMargins.swift
//

import UIKit

extension UIStackView {
    
    /// Sets the layout margins and returns self (chainable).
    /// - Parameter layoutMargins: The edge insets for layout margins.
    @discardableResult public func layoutMargins(_ layoutMargins: UIEdgeInsets) -> Self {
        with { $0.layoutMargins = layoutMargins }
    }
}
