//
//  UIBarButtonItem+HidesSharedBackground.swift
//

import UIKit

extension UIBarButtonItem {
    
    /// Sets whether the shared background should be hidden (iOS 26+).
    /// - Parameter hidesSharedBackground: `true` to hide, `false` to show. Defaults to `true`.
    @discardableResult
    public func hidesSharedBackground(_ hidesSharedBackground: Bool = true) -> Self {
        with { if #available(iOS 26.0, *) { $0.hidesSharedBackground = hidesSharedBackground } }
    }
}
