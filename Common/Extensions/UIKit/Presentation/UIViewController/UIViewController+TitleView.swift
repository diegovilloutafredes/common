//
//  UIViewController+TitleView.swift
//

import UIKit

extension UIViewController {
    
    /// Sets the navigation item's title view and returns self (chainable).
    /// - Parameter titleView: The view to display as the title.
    @discardableResult public func titleView(_ titleView: UIView?) -> Self {
        with { $0.navigationItem.titleView = titleView }
    }
}
