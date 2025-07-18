//
//  UIViewController+DebugMode.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func debugMode() -> Self {
        with { $0.view.debugMode(applyToSubviews: true) }
    }
}
