//
//  UIScrollView+AlwaysBounceVertical.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        with { $0.alwaysBounceVertical = alwaysBounceVertical }
    }
}
