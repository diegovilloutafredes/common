//
//  UIView+SendSelfToBack.swift
//

import UIKit

extension UIView {
    
    /// Sends this view to the back in its superview and returns self (chainable).
    @discardableResult public func sendSelfToBack() -> Self {
        with { $0.superview?.sendToBack($0) }
    }
}
