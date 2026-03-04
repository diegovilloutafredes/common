//
//  UIStackView+RemoveArrangedSubviews.swift
//

import UIKit

extension UIStackView {
    
    /// Removes all arranged subviews from the stack view.
    public func removeArrangedSubviews() { arrangedSubviews.forEach { $0.removeFromSuperview() } }
}
