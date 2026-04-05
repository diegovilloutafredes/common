//
//  UIView+RemoveSubviews.swift
//

import UIKit

extension UIView {
    
    /// Removes all subviews from the view.
    public func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
