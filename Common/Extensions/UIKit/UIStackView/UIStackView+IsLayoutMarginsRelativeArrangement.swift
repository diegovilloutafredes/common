//
//  UIStackView+IsLayoutMarginsRelativeArrangement.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement: Bool) -> Self {
        with { $0.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement }
    }
}
