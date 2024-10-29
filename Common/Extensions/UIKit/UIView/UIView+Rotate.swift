//
//  UIView+Rotate.swift
//

import UIKit

extension UIView {
    @discardableResult public func rotate(_ rotationAngle: Double = .zero) -> Self {
        with { $0.transform = .init(rotationAngle: rotationAngle) }
    }
}
