//
//  UINavigationBar+PrefersLargeTitles.swift
//

import UIKit

// MARK: - PrefersLargeTitles
extension UINavigationBar {
    @discardableResult public func prefersLargeTitles(_ prefersLargeTitles: Bool) -> Self {
        with { $0.prefersLargeTitles = prefersLargeTitles }
    }
}
