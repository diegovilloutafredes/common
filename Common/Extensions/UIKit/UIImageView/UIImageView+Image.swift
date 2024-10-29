//
//  UIImageView+Image.swift
//

import UIKit

extension UIImageView {
    @discardableResult public func image(_ image: UIImage?) -> Self { with { $0.image = image } }
}

extension UIImageView {
    @discardableResult public func image(named: String) -> Self { with { $0.image(.named(named)) } }
}

extension UIImageView {
    @discardableResult public func image(systemName: String) -> Self { with { $0.image(.symbol(systemName)) } }
}
