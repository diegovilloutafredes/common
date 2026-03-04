//
//  UIViewController+ModalTransitionStyle.swift
//

import UIKit

extension UIViewController {
    
    /// Sets the modal transition style and returns self (chainable).
    /// - Parameter modalTransitionStyle: The transition style to set.
    @discardableResult public func modalTransitionStyle(_ modalTransitionStyle: UIModalTransitionStyle) -> Self {
        with { $0.modalTransitionStyle = modalTransitionStyle }
    }
}
