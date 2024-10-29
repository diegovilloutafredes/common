//
//  BackgroundColorable.swift
//

import UIKit

// MARK: - BackgroundColorable
protocol BackgroundColorable: AnyObject {
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
