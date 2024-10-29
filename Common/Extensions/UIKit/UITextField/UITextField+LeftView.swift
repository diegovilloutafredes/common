//
//  UITextField+LeftView.swift
//

import UIKit

extension UITextField {
    @discardableResult public func leftView(_ leftView: UIView) -> Self {
        with {
            $0.leftView = leftView
            $0.leftViewMode(.always)
        }
    }
}
