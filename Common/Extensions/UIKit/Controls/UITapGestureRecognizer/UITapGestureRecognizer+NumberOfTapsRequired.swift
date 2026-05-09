//
//  UITapGestureRecognizer+NumberOfTapsRequired.swift
//

import UIKit

extension UITapGestureRecognizer {
    
    /// Sets the number of taps required and returns self (chainable).
    /// - Parameter numberOfTapsRequired: The number of taps needed to trigger the recognizer.
    @discardableResult public func numberOfTapsRequired(_ numberOfTapsRequired: Int) -> Self {
        with { $0.numberOfTapsRequired = numberOfTapsRequired }
    }
}
