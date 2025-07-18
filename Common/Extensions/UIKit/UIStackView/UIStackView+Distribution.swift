//
//  UIStackView+Distribution.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func distribution(_ distribution: Distribution) -> Self {
        with { $0.distribution = distribution }
    }
}
