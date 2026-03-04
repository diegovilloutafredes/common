//
//  UIImageView+Symbol.swift
//

import UIKit

extension UIImageView {
    
    /// Sets a SF Symbol image with optional configuration and returns self (chainable).
    /// - Parameters:
    ///   - named: The name of the SF Symbol.
    ///   - configuration: Optional symbol configuration.
    @discardableResult public func symbol(_ named: String, with configuration: UIImage.SymbolConfiguration? = nil) -> Self {
        with { $0.image = .init(systemName: named, withConfiguration: configuration) }
    }
}
