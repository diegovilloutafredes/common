//
//  UIViewController+ModalPresentationStyle.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func modalPresentationStyle(_ modalPresentationStyle: UIModalPresentationStyle) -> Self {
        with { $0.modalPresentationStyle = modalPresentationStyle }
    }
}
