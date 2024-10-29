//
//  UIView+SendToBack.swift
//

import UIKit

extension UIView {
    @discardableResult public func sendToBack(_ subview: UIView) -> Self {
        with { $0.sendSubviewToBack(subview) }
    }
}
