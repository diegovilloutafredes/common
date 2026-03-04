//
//  UITextField+RightViewMode.swift
//

import UIKit

extension UITextField {
    
    /// Sets the right view mode and returns self (chainable).
    /// - Parameter rightViewMode: The mode for displaying the right view.
    @discardableResult public func rightViewMode(_ rightViewMode: ViewMode) -> Self {
        with { $0.rightViewMode = rightViewMode }
    }
}
