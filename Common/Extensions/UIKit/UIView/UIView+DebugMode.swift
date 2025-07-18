//
//  UIView+DebugMode.swift
//

import UIKit

extension UIView {
    @discardableResult public func debugMode(applyToSubviews: Bool = false) -> Self {
        with {
            guard applyToSubviews else {
                $0.randomBackgroundColor()
                $0.addFrameInfo()
                return
            }
            $0.applyToAllSubviews {
                $0.randomBackgroundColor()
                $0.addFrameInfo()
            }
        }
    }
}
