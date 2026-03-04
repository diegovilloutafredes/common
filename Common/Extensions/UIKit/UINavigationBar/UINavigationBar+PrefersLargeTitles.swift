//
//  UINavigationBar+PrefersLargeTitles.swift
//

import UIKit

// MARK: - PrefersLargeTitles
extension UINavigationBar {
    
    /// Sets whether the navigation bar prefers large titles and returns self (chainable).
    /// - Parameter prefersLargeTitles: `true` to prefer large titles.
    @discardableResult public func prefersLargeTitles(_ prefersLargeTitles: Bool) -> Self {
        with { $0.prefersLargeTitles = prefersLargeTitles }
    }
}
