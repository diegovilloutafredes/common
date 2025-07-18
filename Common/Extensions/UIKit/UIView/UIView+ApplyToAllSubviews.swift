//
//  UIView+ApplyToAllSubviews.swift
//

import UIKit

extension UIView {
    @discardableResult public func applyToAllSubviews(_ handler: Handler<UIView>) -> Self {
        with {
            $0.subviews.forEach {
                handler($0)
                $0.applyToAllSubviews(handler)
            }
        }
    }
}
