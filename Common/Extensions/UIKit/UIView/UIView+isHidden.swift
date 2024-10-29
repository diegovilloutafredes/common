//
//  UIView+isHidden.swift
//

import UIKit

extension UIView {
    @discardableResult public func isHidden(_ isHidden: Bool) -> Self {
        with { $0.isHidden = isHidden }
    }
}
