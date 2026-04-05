//
//  UIImageView+Image.swift
//

import UIKit

extension UIImageView {
    
    /// Sets the image and returns self (chainable).
    /// - Parameter image: The image to set.
    @discardableResult public func image(_ image: UIImage?) -> Self { with { $0.image = image } }
}

extension UIImageView {
    
    /// Sets the image by name and returns self (chainable).
    /// - Parameter named: The name of the image asset.
    @discardableResult public func image(named: String) -> Self { with { $0.image(.named(named)) } }
}

extension UIImageView {
    
    /// Sets a SF Symbol image and returns self (chainable).
    /// - Parameter systemName: The name of the SF Symbol.
    @discardableResult public func image(systemName: String) -> Self { with { $0.image(.symbol(systemName)) } }
}
