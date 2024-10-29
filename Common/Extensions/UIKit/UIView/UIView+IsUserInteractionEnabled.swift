//
//  UIView+IsUserInteractionEnabled.swift
//

import UIKit

extension UIView {
    @discardableResult public func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        with { $0.isUserInteractionEnabled = isUserInteractionEnabled }
    }
}
