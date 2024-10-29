//
//  UIButton+BackgroundImage.swift
//

import UIKit

extension UIButton {
    @discardableResult public func backgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State = .normal) -> Self {
        with { $0.setBackgroundImage(backgroundImage, for: state) }
    }
}
