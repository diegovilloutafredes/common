//
//  UIBarButtonItem+Image.swift
//

import UIKit

extension UIBarButtonItem {
    @discardableResult public func image(_ image: UIImage?) -> Self {
        with { $0.image = image }
    }
}
