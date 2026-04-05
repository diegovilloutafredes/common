//
//  UIView+SendToBack.swift
//

import UIKit

extension UIView {
    
    /// Sends a subview to the back and returns self (chainable).
    /// - Parameter subview: The subview to send to back.
    @discardableResult public func sendToBack(_ subview: UIView) -> Self {
        with { $0.sendSubviewToBack(subview) }
    }
}
