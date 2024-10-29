//
//  UIViewController+HidesBackButton.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func hidesBackButton(_ hidesBackButton: Bool, animated: Bool = false) -> Self {
        with { $0.navigationItem.setHidesBackButton(hidesBackButton, animated: animated) }
    }
}
