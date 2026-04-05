//
//  BackgroundColorable.swift
//

import UIKit

// MARK: - BackgroundColorable
// MARK: - BackgroundColorable
/// A protocol for objects that can have a background color.
protocol BackgroundColorable: AnyObject {
    
    /// Sets the background color.
    /// - Parameter backgroundColor: The color to set.
    /// - Returns: The object itself for chaining.
    @discardableResult func backgroundColor(_ backgroundColor: UIColor?) -> Self
}

extension UIView: BackgroundColorable {
    @discardableResult public func backgroundColor(_ backgroundColor: UIColor? = .white) -> Self {
        with { $0.backgroundColor = backgroundColor }
    }
}

extension UIViewController: BackgroundColorable {
    @discardableResult public func backgroundColor(_ backgroundColor: UIColor? = .white) -> Self {
        with { $0.view.backgroundColor(backgroundColor) }
    }
}
