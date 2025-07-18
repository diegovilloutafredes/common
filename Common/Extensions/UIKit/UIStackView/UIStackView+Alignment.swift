//
//  UIStackView+Alignment.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func alignment(_ alignment: Alignment) -> Self {
        with { $0.alignment = alignment }
    }
}
