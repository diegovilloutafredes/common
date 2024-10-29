//
//  UIButton+Title.swift
//

import UIKit

extension UIButton {
    @discardableResult public func title(_ title: String?, for state: State = .normal) -> Self {
        with { $0.setTitle(title, for: state) }
    }
}
