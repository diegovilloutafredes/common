//
//  UIViewController+TitleView.swift
//

import UIKit

extension UIViewController {
    @discardableResult public func titleView(_ titleView: UIView?) -> Self {
        with { $0.navigationItem.titleView = titleView }
    }
}
