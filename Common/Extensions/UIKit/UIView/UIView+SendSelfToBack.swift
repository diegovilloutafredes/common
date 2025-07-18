//
//  UIView+SendSelfToBack.swift
//

import UIKit

extension UIView {
    @discardableResult public func sendSelfToBack() -> Self {
        with { $0.superview?.sendToBack($0) }
    }
}
