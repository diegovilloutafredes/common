//
//  UIViewController+IsUserInteractionEnabled.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        with { $0.view.isUserInteractionEnabled(isUserInteractionEnabled) }
    }
}
