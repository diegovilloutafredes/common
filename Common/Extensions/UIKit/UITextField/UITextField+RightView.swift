//
//  UITextField+RightView.swift
//

import UIKit

extension UITextField {
    @discardableResult public func rightView(_ rightView: UIView) -> Self {
        with {
            $0.rightView = rightView
            $0.rightViewMode(.always)
        }
    }
}
