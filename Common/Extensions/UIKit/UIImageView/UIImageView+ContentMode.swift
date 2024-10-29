//
//  UIImageView+ContentMode.swift
//

import UIKit

extension UIImageView {
    @discardableResult public func contentMode(_ contentMode: ContentMode) -> Self {
        with { $0.contentMode = contentMode }
    }
}
