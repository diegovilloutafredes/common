//
//  UIViewController+ModalTransitionStyle.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func modalTransitionStyle(_ modalTransitionStyle: UIModalTransitionStyle) -> Self {
        with { $0.modalTransitionStyle = modalTransitionStyle }
    }
}
