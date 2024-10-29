//
//  UIView+InsetsLayoutMarginsFromSafeArea.swift
//

import UIKit

extension UIView {
    @discardableResult public func insetsLayoutMarginsFromSafeArea(_ insetsLayoutMarginsFromSafeArea: Bool) -> Self {
        with { $0.insetsLayoutMarginsFromSafeArea = insetsLayoutMarginsFromSafeArea }
    }
}
