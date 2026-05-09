//
//  UIViewController+IsModalInPresentation.swift
//

import UIKit

extension UIViewController {
    /// When set to true, it prevents the viewController from being dismissed by swiping down or by touching outside its bounds when it's being presented.
    @discardableResult public func isModalInPresentation(_ isModalInPresentation: Bool = true) -> Self {
        with { $0.isModalInPresentation = isModalInPresentation }
    }
}
