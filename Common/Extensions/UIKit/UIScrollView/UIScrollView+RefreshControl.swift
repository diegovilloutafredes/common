//
//  UIScrollView+RefreshControl.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func refreshControl(_ refreshControl: UIRefreshControl) -> Self {
        with { $0.refreshControl = refreshControl }
    }
}
