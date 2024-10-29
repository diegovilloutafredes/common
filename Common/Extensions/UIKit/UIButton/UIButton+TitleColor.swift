//
//  UIButton+TitleColor.swift
//

import UIKit

extension UIButton {
    @discardableResult public func titleColor(_ titleColor: UIColor?, for state: State = .normal) -> Self { with { $0.setTitleColor(titleColor, for: state) } }
}
