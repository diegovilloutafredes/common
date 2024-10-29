//
//  UIImageView+Symbol.swift
//

import UIKit

extension UIImageView {
    @discardableResult public func symbol(_ named: String, with configuration: UIImage.SymbolConfiguration? = nil) -> Self {
        with { $0.image = .init(systemName: named, withConfiguration: configuration) }
    }
}
