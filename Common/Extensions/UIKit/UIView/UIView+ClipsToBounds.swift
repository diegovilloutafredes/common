//
//  UIView+ClipsToBounds.swift
//

import UIKit

extension UIView {
    @discardableResult public func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        with { $0.clipsToBounds = clipsToBounds }
    }
}
