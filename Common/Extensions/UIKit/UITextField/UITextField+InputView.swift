//
//  UITextField+InputView.swift
//

import UIKit

extension UITextField {
    @discardableResult public func inputView(_ inputView: UIView) -> Self {
        with { $0.inputView = inputView }
    }
}
