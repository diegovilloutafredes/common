//
//  UIViewController+ModalPresentationStyle.swift
//

import UIKit

extension UIViewController {
    
    /// Sets the modal presentation style and returns self (chainable).
    /// - Parameter modalPresentationStyle: The presentation style to set.
    @discardableResult public func modalPresentationStyle(_ modalPresentationStyle: UIModalPresentationStyle) -> Self {
        with { $0.modalPresentationStyle = modalPresentationStyle }
    }
}
