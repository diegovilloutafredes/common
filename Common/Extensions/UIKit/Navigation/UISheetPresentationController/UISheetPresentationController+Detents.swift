//
//  UISheetPresentationController+.swift
//

import UIKit

extension UISheetPresentationController {
    
    /// Sets the detents (heights) for the sheet and returns self (chainable).
    /// - Parameter detents: An array of detents to set.
    @discardableResult public func detents(_ detents: [Detent]) -> Self { with { $0.detents = detents } }
}
