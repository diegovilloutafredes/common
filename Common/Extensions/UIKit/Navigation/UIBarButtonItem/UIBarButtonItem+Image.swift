//
//  UIBarButtonItem+Image.swift
//

import UIKit

extension UIBarButtonItem {
    
    /// Sets the image and returns self (chainable).
    /// - Parameter image: The image to set.
    @discardableResult public func image(_ image: UIImage?) -> Self {
        with { $0.image = image }
    }
}
